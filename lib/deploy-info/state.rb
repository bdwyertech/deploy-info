# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: deploy-info
# DeployInfo:: State
#
# Copyright (C) 2016 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'deploy-info/config'
require 'deploy-info/util'

module DeployInfo
  # => This is the State controller.  It manages State information
  module State
    extend self

    ##############################
    # =>   State Operations   <= #
    ##############################

    attr_accessor :state

    def state
      @state ||= Util.parse_json_config(Config.state_file) || []
    end

    def find_state(node)
      state.detect { |h| h[:name].casecmp(node).zero? }
    end

    def update_state(hash) # rubocop: disable AbcSize
      # => Check if Node Already Exists
      existing = find_state(hash[:name])
      if existing # => Update the Existing Node
        state.delete(existing)
        audit_string = [DateTime.now, hash[:creator]].join(' - ')
        existing[:last_modified] = existing[:last_modified].is_a?(Array) ? existing[:last_modified].take(5).unshift(audit_string) : [audit_string]
        hash = existing
      end

      # => Update the State
      state.push(hash)

      # => Write Out the Updated State
      write_state
    end

    # => Add Node to the State
    def add_state(node, user, params) # rubocop: disable MethodLength, AbcSize
      # => Create a Node-State Object
      (n = {}) && (n[:name] = node)
      n[:created] = DateTime.now
      n[:creator] = user
      # => Parse our Field Values
      %w(type).each do |opt|
        n[opt.to_sym] = params[opt] if params[opt]
      end
      # => Parse our Booleans
      %w(protected).each do |opt|
        n[opt.to_sym] = true if params[opt] && %w(true 1).any? { |x| params[opt].to_s.casecmp(x) == 0 }
      end
      # => Build the Updated State
      update_state(n)
      # => Return the Added Node
      find_state(node)
    end

    # => Remove Node from the State
    def delete_state(node)
      # => Find the Node
      existing = find_state(node)
      return 'Node not present in state' unless existing
      # => Delete the Node from State
      state.delete(existing)
      # => Write Out the Updated State
      write_state
      # => Return the Deleted Node
      existing
    end

    def write_state
      # => Sort & Unique State
      state.sort_by! { |h| h[:name].downcase }.uniq!

      # => Write Out the Updated State
      Util.write_json_config(Config.state_file, state)
    end
  end
end
