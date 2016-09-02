# encoding: UTF-8
# rubocop: disable LineLength
# Deployment Information Provider for RunDeck
# Brian Dwyer - Intelligent Digital Services - 9/1/16

require 'deploy-info/cli'
require 'deploy-info/config'
require 'deploy-info/state'
require 'deploy-info/util'
require 'deploy-info/version'

# => Deployment Information API
module DeployInfo
  # => The Sinatra API should be Lazily-Loaded, such that the CLI arguments and/or configuration files are respected
  autoload :API, 'deploy-info/api'
end
