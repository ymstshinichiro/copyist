# Copyist
This application is a tool that can parse a file written in markdown and generate multiple Github isuue tickets at once.

The word 'Copyist' means 'Hikko (筆耕)' in Japanese.

## Installation

1. clone this repository
1. `$ bundle install`
## How to use

### step1. set ENV
- set your github personal token to GITHUB_PERSONAL_TOKEN
  - `$ export GITHUB_PERSONAL_TOKEN={YOUR_TOKEN}`

- set your name, your repo to .env file

### step2. ready markdown file

example

```
### foo
- fizz
    - bazz
- fizzbazz
### bar
- aaa
    - **bbb**
```

### step3. run copyist
1. `$ bundle exec exe/copyist job path/to/markdown_file.md`


## Development

## Contributing

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Copyist project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/copyist/blob/master/CODE_OF_CONDUCT.md).
