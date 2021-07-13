require 'copyist'
require 'net/http'
require 'json'
require 'dotenv'

module Copyist
  class Job
    IssueTicket = Struct.new(:title, :description)

    def initialize(file)
      Dotenv.load
      @file = file
    end

    def run
      puts 'make tickets to Github from markdown'

      tickets_from_markdown.each do |ticket|
        pp ticket
        # response = request_to_github(ticket)
        # puts response.body
      end
      puts 'process finished'
    rescue => e
      puts ['fatal error.', '-------', e.backtrace, '------'].flatten.join("\n")
    end

    private

    def tickets_from_markdown
      tickets = []
      get_markdown.each do |line|
        case
        when line[0..1] == '# '  then next
        when line[0..2] == '## ' then next
        when line[0..2] == '###' then tickets << IssueTicket.new(line.gsub("###", ''), [])
        else tickets.last.description << line
        end
      end

      tickets.each{ |i| i.description = i.description.join }
      tickets
    end

    def request_to_github(ticket)
      uri = get_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"

      headers = { Authorization: "token #{ENV['GITHUB_PERSONAL_TOKEN']}" }
      body = make_request_body(ticket)

      http.post(uri.path, body.to_json, headers)
    end

    def make_request_body(ticket)
      {
        title:  ticket.title,
        body:   ticket.description,
        labels: ENV['LABELS'].split(',')
      }
    end

    def get_uri
      URI.parse("https://api.github.com/repos/#{ENV['GITHUB_USER_NAME']}/#{ENV['GITHUB_REPO_NAME']}/issues")
    end

    def get_markdown
      File.new(@file).readlines
    end
  end
end