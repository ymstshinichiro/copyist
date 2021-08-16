# frozen_string_literal: true

module Copyist
  class Jira
    IssueTicket = Struct.new(:title, :description, :labels, :parent)

    attr_accessor(:title_identifire, :skip_identifires, :label_identifire, :global_labels, :template_file_path,
                  :basic_auth, :parent_identifire)

    def initialize(argv)
      @source_md_file_path = argv

      env_path = ENV["ENVFILE_PATH"]
      Dotenv.load(env_path) if env_path && !env_path.empty?

      if ENV["JIRA_USER_NAME"].empty? || ENV["JIRA_PROJECT_NAME"].empty?
        raise "set JIRA_USER_NAME and JIRA_PROJECT_NAME to env"
      end
      raise "set TITLE_IDENTIFIRE to env" if ENV["TITLE_IDENTIFIRE"].empty?
      raise "set JIRA_PARENT_PROJECT_IDENTIFIRE to env" if ENV["JIRA_PARENT_PROJECT_IDENTIFIRE"].empty?

      @parent_identifire = "#{ENV["JIRA_PARENT_PROJECT_IDENTIFIRE"]} "

      @title_identifire = "#{ENV["TITLE_IDENTIFIRE"]} "
      @skip_identifires = ENV["SKIP_IDENTIFIRES"]&.size&.nonzero? ? Regexp.new("^#{ENV["SKIP_IDENTIFIRES"].split(",").join(" |")}") : nil
      @label_identifire = ENV["LABEL_IDENTIFIRE"]&.size&.nonzero? ? "#{ENV["LABEL_IDENTIFIRE"]} " : nil

      @global_labels      = ENV["GLOBAL_LABELS"]&.size&.nonzero? ? ENV["GLOBAL_LABELS"] : nil
      @template_file_path = ENV["TEMPLATE_FILE_PATH"]&.size&.nonzero? ? ENV["TEMPLATE_FILE_PATH"] : nil

      @basic_auth = Base64.urlsafe_encode64("#{ENV["JIRA_USER_NAME"]}:#{ENV["JIRA_API_TOKEN"]}")
    end

    def run
      puts "make subtasks to JIRA from markdown"

      tickets_from_markdown.each do |ticket|
        response = request_to_jira(ticket)
        puts response.message
      end

      puts "process finished"
    rescue StandardError => e
      puts ["fatal error.", "-------", e.backtrace, "------"].flatten.join("\n")
    end

    def tickets_from_markdown
      tickets = []
      get_markdown.each do |line|
        next if skip_identifires && line.match?(skip_identifires)

        if line.match?(/^#{title_identifire}/)
          tickets << IssueTicket.new(line.gsub(/#{title_identifire}|\*|\*\*|`/, ""), [], [], nil)

        elsif line.match?(/^#{parent_identifire}/)
          tickets&.last&.parent = line.gsub(/#{parent_identifire}|\*|\*\*|`/, "")

        elsif label_identifire && line.match?(/^#{label_identifire}/)
          (tickets&.last&.labels || []) << line.gsub(label_identifire, "").chomp.split(",").map(&:strip)

        else
          (tickets&.last&.description || []) << line
        end
      end

      tickets.each { |i| i.description = make_description(i.description) }
      tickets
    end

    private

    def make_description(description_text_array)
      description = description_text_array.join("\n")

      if template_file_path
        template = File.open(template_file_path, "r", &:read)
        description = template.gsub("{ticket_description_block}", description)
      end

      description
    end

    def request_to_jira(ticket)
      uri = get_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme === "https"

      headers = { "Authorization" => "Basic #{basic_auth}" }
      headers["Content-Type"] = "application/json"
      body = make_request_body(ticket)

      http.post(uri.path, body.to_json, headers)
    end

    def make_request_body(ticket)
      {
        fields: {
          project: { key: ENV["JIRA_PROJECT_NAME"] },
          parent: { key: ticket.parent },
          summary: ticket.title,
          description: ticket.description,
          issuetype: { "id": ENV["JIRA_ISSUE_TYPE_ID"] },
          labels: (global_labels&.split(",")&.map(&:strip) + ticket.labels).flatten.uniq
        }
      }
    end

    def get_uri
      URI.parse("https://#{ENV["JIRA_SUBDOMAIN_NAME"]}.atlassian.net/rest/api/2/issue/")
    end

    def get_markdown
      File.new(@source_md_file_path).readlines.map(&:chomp)
    end
  end
end
