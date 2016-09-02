# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: deploy-info
# Module:: VCS
#
# Copyright (C) 2016 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'github_api'
require 'deploy-info/config'

module DeployInfo
  # => This is the Github Module. It interacts with Github.
  module Github
    extend self

    def ghclient
      # => Parameter Overrides
      Github.configure do |cfg|
        cfg.oauth_token = Config.query_params['gh_oauth_token'] || Config.github_oauth_token
      end

      # => Instantiate a new GitHub Client
      Github::Client.new
    end

    def tip
      org, repo = Config.query_params['gh_repo'].split('/').map { |r| String(r) }
      rev = Config.query_params['gh_rev']
      puts org.to_s
      puts repo.to_s
      # => Pull the SHA
      ghclient.git_data.trees.get(org, repo, rev).first[1]
    end
  end
end
