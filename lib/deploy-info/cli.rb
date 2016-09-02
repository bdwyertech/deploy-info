# Encoding: UTF-8
# rubocop: disable LineLength, MethodLength, AbcSize
#
# Gem Name:: deploy-info
# DeployInfo:: CLI
#
# Copyright (C) 2016 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'mixlib/cli'
require 'deploy-info/config'
require 'deploy-info/util'

module DeployInfo
  #
  # => Deploy-Info Launcher
  #
  module CLI
    extend self
    #
    # => Options Parser
    #
    class Options
      # => Mix-In the CLI Option Parser
      include Mixlib::CLI

      option :github_oauth_token,
             short: '-g TOKEN',
             long: '--github-oauth-token TOKEN',
             description: 'OAuth Token to use for querying GitHub'

      option :nr_api_key,
             short: '-n KEY',
             long: '--nr-api-key KEY',
             description: 'NewRelic API Key for deploy notifications to NewRelic'

      option :cache_timeout,
             short: '-t CACHE_TIMEOUT',
             long: '--timeout CACHE_TIMEOUT',
             description: 'Sets the cache timeout in seconds for API query response data.'

      option :config_file,
             short: '-c CONFIG',
             long: '--config CONFIG',
             description: 'The configuration file to use, as opposed to command-line parameters (optional)'

      option :state_file,
             short: '-s STATE',
             long: '--state-json STATE',
             description: "The JSON file containing node state & auditing information (Default: #{Config.state_file})"

      option :bind,
             short: '-b HOST',
             long: '--bind HOST',
             description: "Listen on Interface or IP (Default: #{Config.bind})"

      option :port,
             short: '-p PORT',
             long: '--port PORT',
             description: "The port to run on. (Default: #{Config.port})"

      option :environment,
             short: '-e ENV',
             long: '--env ENV',
             description: 'Sets the environment for deploy-info to execute under. Use "development" for more logging.',
             default: 'production'
    end

    # => Launch the Application
    def run(argv = ARGV)
      # => Parse CLI Configuration
      cli = Options.new
      cli.parse_options(argv)

      # => Parse JSON Config File (If Specified & Exists)
      json_config = Util.parse_json_config(cli.config[:config_file])

      # => Grab the Default Values
      default = DeployInfo::Config.options

      puts cli.config[:config_file]
      puts json_config
      puts 'AYO!'

      # => Merge Configuration (JSON File Wins)
      config = [default, json_config, cli.config].compact.reduce(:merge)

      # => Apply Configuration
      DeployInfo::Config.setup do |cfg|
        cfg.config_file         = config[:config_file]
        cfg.cache_timeout       = config[:cache_timeout].to_i
        cfg.bind                = config[:bind]
        cfg.port                = config[:port]
        cfg.state_file          = config[:state_file]
        cfg.environment         = config[:environment].to_sym
        cfg.github_oauth_token  = config[:github_oauth_token]
        cfg.nr_api_key          = config[:nr_api_key]
      end

      # => Launch the API
      DeployInfo::API.run!
    end
  end
end
