# Encoding: UTF-8
# rubocop: disable LineLength, AbcSize, MethodLength
#
# Gem Name:: deploy-info
# DeployInfo:: Notifier
#
# Copyright (C) 2016 Brian Dwyer - Intelligent Digital Services
#
# All rights reserved - Do Not Redistribute
#

require 'deploy-info/git'
require 'json'
require 'net/http'
require 'uri'

module DeployInfo
  # => Deploy Notification Methods
  module Notifier
    extend self

    ########################
    # =>    NewRelic    <= #
    ########################

    def newrelic
      return unless Config.query_params['nr_app_id']

      # => Grab the NewRelic Application ID
      nr_app_id = Config.query_params['nr_app_id']

      # => Build the URI & POST Request
      uri = URI.parse("https://api.newrelic.com/v2/applications/#{nr_app_id}/deployments.json")
      request = Net::HTTP::Post.new(uri)

      # => Set Headers
      request.content_type = 'application/json'
      request['X-Api-Key'] = Config.query_params['nr_api_key'] || Config.nr_api_key
      puts Config.nr_api_key

      # => Build the JSON Payload
      request.body = {
        deployment: {
          revision: Git.revision,
          user: Config.query_params['user'],
          description: Config.query_params['comment']
        }
      }.to_json

      # => Send the Deployment Notification
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
    end

    #######################
    # =>    Rollbar    <= #
    #######################

    def rollbar
      # => Build the Data Structure
      data = {}
      data[:access_token] = Config.query_params['rb_token']
      data[:environment] = Config.query_params['environment']
      data[:revision] = Git.revision
      data[:local_username] = Config.query_params['user']
      data[:comment] = Config.query_params['comment']

      # => Parse the Destination API URI
      uri = URI.parse('https://api.rollbar.com/api/1/deploy/')

      # => Construct the POST Request
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(data)

      # => Send the Deployment Notification
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
    end
  end
end
