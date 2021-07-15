# frozen_string_literal: true

require_relative "../test_helper"

module Copyist
  class JobTest < Minitest::Test
    FILE_STUB = 'path/to/file'
    ENV_FILE = '.env.test'

    def test_that_it_has_a_file
      assert Copyist::Job.new(FILE_STUB, ENV_FILE).instance_variables.include?(:@file)
    end


    def test_that_it_returns_markdown
      markdown = <<~"DOC"
        # level1
        ## level2
        ##### hoge - this line skip
        labels: frontend,backend
        ### foo
        - fizz
            - bazz
        - fizzbazz
        skip_line: aaa
        DOC

      target = Copyist::Job.new(FILE_STUB, ENV_FILE)

      target.stub(:get_markdown, markdown.scan(/.*\n/)) do
        result = target.tickets_from_markdown

        assert result.first.title == "level1\n"

        assert result.first.description == <<~"RESULT"
        ## level2
        ### foo
        - fizz
            - bazz
        - fizzbazz
        RESULT

        assert result.first.labels == ['frontend', 'backend']
      end
    end
  end
end
