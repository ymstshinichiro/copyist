module Copyist
  class Job
    IssueTicket = Struct.new(:title, :description, :labels)

    attr_accessor :title_identifire, :skip_identifires, :label_identifire, :global_labels, :template_file_path

    # FIXME: ここでENV読み分けてるの微妙な気がしてる. が、設定ファイル切り替えやすいというメリットもある？
    def initialize(argv, env = '.env')
      @source_md_file_path = argv

      Dotenv.load(env)
      raise 'set GITHUB_USER_NAME and GITHUB_REPO_NAME to .env file' if (ENV['GITHUB_USER_NAME'].empty? || ENV['GITHUB_REPO_NAME'].empty?)
      raise 'set TITLE_IDENTIFIRE to .env file' if ENV['TITLE_IDENTIFIRE'].empty?

      @title_identifire = "#{ENV['TITLE_IDENTIFIRE']} "
      @skip_identifires = ENV['SKIP_IDENTIFIRES']&.size&.nonzero? ? Regexp.new("^#{ENV['SKIP_IDENTIFIRES'].split(',').join(' |')}") : nil
      @label_identifire = ENV['LABEL_IDENTIFIRE']&.size&.nonzero? ? "#{ENV['LABEL_IDENTIFIRE']} " : nil

      @global_labels      = ENV['GLOBAL_LABELS']&.size&.nonzero? ? ENV['GLOBAL_LABELS'] : nil
      @template_file_path = ENV['TEMPLATE_FILE_PATH']&.size&.nonzero? ? ENV['TEMPLATE_FILE_PATH'] : nil
    end

    def run
      puts 'make tickets to Github from markdown'

      tickets_from_markdown.each do |ticket|
        response = request_to_github(ticket)
        puts response.message
      end
      puts 'process finished'
    rescue => e
      puts ['fatal error.', '-------', e.backtrace, '------'].flatten.join("\n")
    end

    def tickets_from_markdown
      tickets = []
      get_markdown.each do |line|
        next if skip_identifires && line.match?(skip_identifires)

        if line.match?(/^#{title_identifire}/)
          tickets << IssueTicket.new(line.gsub(title_identifire, ''), [], [])

        elsif label_identifire && line.match?(/^#{label_identifire}/)
          (tickets&.last&.labels || []) << line.gsub(label_identifire, '').chomp.split(',').map(&:strip)

        else
          (tickets&.last&.description || []) << line
        end
      end

      tickets.each{ |i| i.description = make_description(i.description) }
      tickets
    end

    private

    def make_description(description_text_array)
      description = description_text_array.join

      if template_file_path
        template = File.open(template_file_path, "r") { |f| f.read }
        description = template.gsub('{ticket_description_block}', description)
      end

      description
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
        labels: (global_labels&.split(',')&.map(&:strip) + ticket.labels).flatten.uniq
      }
    end

    def get_uri
      URI.parse("https://api.github.com/repos/#{ENV['GITHUB_USER_NAME']}/#{ENV['GITHUB_REPO_NAME']}/issues")
    end

    def get_markdown
      File.new(@source_md_file_path).readlines
    end
  end
end