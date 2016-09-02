# Encoding: UTF-8
# rubocop: disable LineLength
#
# Gem Name:: deploy-info
# DeployInfo:: Git
#
# Copyright (C) 2016 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'deploy-info/config'
require 'github_api'

module DeployInfo
  # => This is the Git Module. It interacts with Git resources.
  module Git
    extend self

    def ghclient
      # => Instantiate a new GitHub Client
      Github::Client.new
    end

    def revision # rubocop: disable AbcSize
      # => Grab the Supplied Revision
      rev = Config.query_params['revision'] || return
      return rev unless Config.query_params['gh_repo']

      # => Break down the Params
      org, repo = Config.query_params['gh_repo'].split('/').map { |r| String(r) }
      return rev unless org && repo

      begin
        # => Pull the Shorthand SHA
        ghclient.git_data.trees.get(org, repo, rev).first[1][0, 7]
      rescue Github::Error::NotFound
        # => Return the Supplied Revision if Github Borks
        rev
      end
    end
  end
end
