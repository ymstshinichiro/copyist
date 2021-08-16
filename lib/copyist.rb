# frozen_string_literal: true

require "thor"
require "net/http"
require "json"
require "dotenv"
require "base64"

require "copyist"
require_relative "copyist/version"
require_relative "copyist/application"
require_relative "copyist/job"
require_relative "copyist/jira"
