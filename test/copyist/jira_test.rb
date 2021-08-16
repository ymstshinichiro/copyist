# frozen_string_literal: true

require_relative "../test_helper"

module Copyist
  class JiraTest < Minitest::Test
    FILE_STUB = "path/to/file"

    def test_that_it_returns_tickets_from_markdown
      ENV["ENVFILE_PATH"] = ".env.test"

      markdown = <<~"DOC"
        # **level1** *hoge* `fuga`
         parent: PROJECT-123
        ## level2
        ##### hoge - this line skip
        labels: frontend,backend
        ### foo
        - fizz
            - bazz
        - fizzbazz
        skip_line: aaa
      DOC

      Tempfile.create("foo") do |f|
        f.write(markdown)
        f.rewind

        target = Copyist::Jira.new(f.path)
        result = target.tickets_from_markdown

        assert result.first.title == "level1 hoge fuga"

        assert result.first.description == <<~RESULT.chomp
          ## level2
          ### foo
          - fizz
              - bazz
          - fizzbazz
        RESULT

        assert result.first.labels.flatten == %w[frontend backend]

        assert result.first.parent == "PROJECT-123"
      end
    end
  end
end
