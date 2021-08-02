# frozen_string_literal: true

require_relative "../test_helper"

module Copyist
  class JobTest < Minitest::Test
    FILE_STUB = 'path/to/file'

    def test_that_it_returns_markdown
      ENV['ENVFILE_PATH'] = '.env.test'
      markdown = <<~"DOC"
        # **level1** *hoge* `fuga`
        ## level2
        ##### hoge - this line skip
        labels: frontend,backend
        ### foo
        - fizz
            - bazz
        - fizzbazz
        skip_line: aaa
        DOC

      target = Copyist::Job.new(FILE_STUB)

      target.stub(:get_markdown, markdown.scan(/.*\n/)) {
        result = target.tickets_from_markdown

        assert result.first.title == "level1 hoge fuga\n"

        assert result.first.description == <<~"RESULT"
        ## level2
        ### foo
        - fizz
            - bazz
        - fizzbazz
        RESULT

        assert result.first.labels.flatten == ['frontend', 'backend']
      }
    end
  end
end
