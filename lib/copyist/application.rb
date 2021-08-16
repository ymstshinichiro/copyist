# frozen_string_literal: true

module Copyist
  class Application < Thor
    def self.exit_on_failure?
      true
    end

    desc "job path/to/markdown_file.md", "Parses the markdown file to creates a issue"
    def job(file)
      Copyist::Job.new(file).run
    end

    desc "jira path/to/markdown_file.md", "Parses the markdown file to creates a jira-subtasks"
    def jira(file)
      Copyist::Jira.new(file).run
    end
  end
end
