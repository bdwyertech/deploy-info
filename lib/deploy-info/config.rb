# Encoding: UTF-8
#
# Gem Name:: deploy-info
# DeployInfo:: Config
#
# Copyright (C) 2016 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'deploy-info/helpers/configuration'
require 'pathname'

module DeployInfo
  # => This is the Configuration module.
  module Config
    extend self
    extend Configuration

    # => Gem Root Directory
    define_setting :root, Pathname.new(File.expand_path('../../../', __FILE__))

    # => My Name
    define_setting :author, 'Brian Dwyer - Intelligent Digital Services'

    # => Application Environment
    define_setting :environment, :production

    # => Sinatra Configuration
    define_setting :port, '9128'
    define_setting :bind, 'localhost'
    define_setting :cache_timeout, 30

    # => Config File
    define_setting :config_file, File.join(root, 'config', 'config.json')

    # => State File
    define_setting :state_file, File.join(root, 'config', 'state.json')

    #
    # => API Configuration
    #
    # => Github OAuth Token
    define_setting :github_oauth_token

    # => NewRelic API Key
    define_setting :nr_api_key

    #
    # => Facilitate Dynamic Addition of Configuration Values
    #
    # => @return [class_variable]
    #
    def add(config = {})
      config.each do |key, value|
        define_setting key.to_sym, value
      end
    end

    #
    # => Facilitate Dynamic Removal of Configuration Values
    #
    # => @return nil
    #
    def clear(config)
      Array(config).each do |setting|
        delete_setting setting
      end
    end

    #
    # => List the Configurable Keys as a Hash
    #
    # @return [Hash]
    #
    def options
      map = DeployInfo::Config.class_variables.map do |key|
        [key.to_s.tr('@', '').to_sym, class_variable_get(:"#{key}")]
      end
      Hash[map]
    end
  end
end
