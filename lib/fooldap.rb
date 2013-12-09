require 'ldap/server'

module Fooldap
  class Server < LDAP::Server
    def initialize(options={})
      @users = {}
      @groups = []
      super(default_options.merge(options))
    end

    def add_user(user, pass)
      @users[user] = pass
    end

    def add_group(group, users)
      @groups << [group, users]
    end

    def valid_credentials?(user, pass)
      @users.has_key?(user) && @users[user] == pass
    end

    def find_users(basedn, filter)
      basedn_regex = /#{Regexp.escape(basedn)}$/
      filter_regex = /^#{filter[1]}=#{filter[3]}$/

      @users.keys.select { |dn|
        dn =~ basedn_regex && dn.split(",").grep(filter_regex).any?
      }
    end

    def groups
      @groups
    end

    def find_groups(user)
      groups.select { |group, users| users.include? user }
    end

    def default_options
      {
          :operation_class => ::Fooldap::Operation,
          :operation_args => [self]
      }
    end
  end

  class Operation < LDAP::Server::Operation
    def initialize(connection, messageID, server)
      super(connection, messageID)
      @server = server
    end

    def simple_bind(version, dn, password)
      unless dn
        raise LDAP::ResultError::InappropriateAuthentication,
              "This server does not support anonymous bind"
      end

      unless @server.valid_credentials?(dn, password)
        raise LDAP::ResultError::InvalidCredentials,
              "Invalid credentials"
      end
    end

    def search(basedn, scope, deref, filter, attrs=nil)
      group_filter = [:eq, "objectclass", nil, "groupofNames"]

      if filter == [:true]
        groups = @server.groups.select { |dn, users| dn =~ /#{basedn}/ }
        return groups.each { |dn, users| send_group_result(dn, users) }
      end

      if filter.first == :eq
        if filter == group_filter
          return @server.groups.each { |group| send_group_result(*group) }
        else
          return @server.find_users(basedn, filter).each { |dn| send_SearchResultEntry(dn, {}) }
        end
      elsif filter.first == :and
        if filter[1] == group_filter
          member_eq = filter[2]
          if member_eq[0] == :eq and member_eq[1] == 'member'
            user_dn = member_eq[3]
            return @server.find_groups(user_dn).each { |group| send_group_result(*group) }
          end
        end
      end
      raise LDAP::ResultError::UnwillingToPerform, "Only some matches are supported"
    end

    private

    def send_group_result(group, users)
      user_names = users.map { |user| /uid=(?<user_name>.*?),/.match(user)[:user_name] }
      avs = {'member' => users,
             'memberuid' => user_names,
             'objectclass' => ["groupofNames"],
             'cn' => [/cn=(?<group_name>.*?),/.match(group)[:group_name]]}
      send_SearchResultEntry(group, avs)
    end
  end
end

