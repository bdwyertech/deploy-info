# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: deploy-info
# DeployInfo:: API
#
# Copyright (C) 2016 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

# => NOTE: Anything other than a STATUS 200 will trigger an error in the RunDeck plugin due to a hardcode in org.boon.HTTP

require 'sinatra/base'
require 'sinatra/namespace'
require 'json'
require 'rack/cache'
require 'deploy-info/notifier'
require 'deploy-info/config'
require 'deploy-info/state'

# => Deployment Information Provider for RunDeck
module DeployInfo
  # => HTTP API
  class API < Sinatra::Base
    #######################
    # =>    Sinatra    <= #
    #######################

    # => Configure Sinatra
    enable :logging, :static, :raise_errors # => disable :dump_errors, :show_exceptions
    set :port, Config.port || 8080
    set :bind, Config.bind || 'localhost'
    set :environment, Config.environment || :production

    # => Enable NameSpace Support
    register Sinatra::Namespace

    if development?
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    use Rack::Cache do
      set :verbose, true
      set :metastore,   'file:' + File.join(Dir.tmpdir, 'rack', 'meta')
      set :entitystore, 'file:' + File.join(Dir.tmpdir, 'rack', 'body')
    end

    ########################
    # =>    JSON API    <= #
    ########################

    # => Current Configuration & Healthcheck Endpoint
    get '/config' do
      content_type 'application/json'
      JSON.pretty_generate(
        [
          DeployInfo.inspect + ' is up and running!',
          'Author: ' + Config.author,
          'Environment: ' + Config.environment.to_s,
          'Root: ' + Config.root.to_s,
          'Config File: ' + (Config.config_file if File.exist?(Config.config_file)).to_s,
          'State File: ' + (Config.state_file if File.exist?(Config.state_file)).to_s,
          { State: State.state.map { |n| n[:name] } },
          'Params: ' + params.inspect,
          'Cache Timeout: ' + Config.cache_timeout.to_s,
          'BRIAN IS COOooooooL',
          { AppConfig: Config.options },
          { 'Sinatra Info' => env }
        ].compact
      )
    end

    get '/state' do
      content_type 'application/json'
      State.state.to_json
    end

    ########################
    # =>    JSON API    <= #
    ########################

    namespace '/deploy/v1' do
      # => Define our common namespace parameters
      before do
        # => This is a JSON API
        content_type 'application/json'

        # => Make the Params Globally Accessible
        Config.define_setting :query_params, params

        # => Parameter Overrides
        Github.configure do |cfg|
          cfg.oauth_token = params['gh_oauth_token'] || Config.github_oauth_token
        end
      end

      # => Clean Up
      after do
        # => Reset the API Client to Default Values
        # => Notifier.reset!
      end

      # => Notify Deploys
      post '/notify' do
        resp = {}
        resp['NewRelic'] = JSON.parse(Notifier.newrelic.body) if params['nr_app_id']
        resp['Rollbar'] = JSON.parse(Notifier.rollbar.body) if params['rb_token']
        resp.to_json
      end

      # => Parse Revision
      [:get, :post].each do |method|
        send method, '/revision' do
          Git.revision.to_json
        end
      end
    end
  end
end
