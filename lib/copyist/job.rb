module Copyist
  class Job
    IssueTicket = Struct.new(:title, :description, :labels)

    # FIXME: ここでENV読み分けてるの微妙な気がしてる. が、設定ファイル切り替えやすいというメリットもある？
    def initialize(file, env = '.env')
      Dotenv.load(env)
      raise 'set GITHUB_USER_NAME and GITHUB_REPO_NAME to .env file' if (ENV['GITHUB_USER_NAME'].empty? || ENV['GITHUB_REPO_NAME'].empty?)
      raise 'set TITLE_IDENTIFIRE to .env file' if ENV['TITLE_IDENTIFIRE'].empty?

      @file = file
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

      tickets.each{ |i| i.description = i.description.join }
      tickets
    end

    private

    # FIXME: 定数にするとテストがうまくいかなかったのでメソッドにした
    def title_identifire
      "#{ENV['TITLE_IDENTIFIRE']} "
    end

    def skip_identifires
      return nil if ENV['SKIP_IDENTIFIRES'].size.zero?

      Regexp.new("^#{ENV['SKIP_IDENTIFIRES'].split(',').join(' |')}")
    end

    def label_identifire
      return nil if ENV['LABEL_IDENTIFIRE'].size.zero?

      "#{ENV['LABEL_IDENTIFIRE']} "
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
        labels: (ENV['GLOBAL_LABELS']&.split(',')&.map(&:strip) + ticket.labels).flatten.uniq
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