module Copyist
  class Application < Thor
    def self.exit_on_failure?
      true
    end

    desc "job path/to/markdown_file.md", "Parses the markdown file to creates a issue"
    def job(file)
      Copyist::Job.new(file).run
    end
  end
end
