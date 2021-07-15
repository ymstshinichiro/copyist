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

- set target github user name, target github repository name to .env file

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


## Required or Optional Settings
#### TITLE_IDENTIFIRE (requires)
An identifier to determine which line to use as the title of the ticket.
Determine if it matches the beginning of a line.
Add a space after the set string to judge.

example)

```
# when you set '#' as the TITLE_IDENTIFIRE

match -> '# This is title.'

not match -> '#This is title.'
not match -> '## This is title.'
```

#### SKIP_IDENTIFIRES (optional)
Identifier to determine which lines you do not want to include in the ticket.
If it doesn't exist, ignore it.
You can specify multiple values separated by commas.
Determine if it matches the beginning of a line.
Add a space after the set string to judge.

example)

```
# when you set 'aaa,bbb:' as the SKIP_IDENTIFIRES

match -> 'aaa This line skipped.'
match -> 'bbb: This line skipped.'

not match -> ' aaa This line skipped.'
not match -> 'aaaline skipped.'
not match -> 'bbb line skipped.'
```

#### LABEL_IDENTIFIRE (optional)
Identifier to determine the line representing the label to be given to the ticket.
Enter a comma-separated list of labels to be set on the line to be judged.
Determine if it matches the beginning of a line.
Add a space after the set string to judge.


example)

```
# when you set 'labels:' as the LABEL_IDENTIFIRE

match -> 'labels: labelA,labelB'  -> tickets add label 'labelA' and 'labelB'
match -> 'labels: labelA, labelB'  -> tickets add label 'labelA' and 'labelB'  (Spaces will be removed)

not match -> 'labels:labelA,labelB'  -> No label will be set on the ticket.
```

#### GLOBAL_LABELS (optional)
Specify the label to be set for all tickets.
Enter a comma-separated list of labels to be set on the line to be judged.
You can specify multiple values separated by commas.


## Development

## Contributing

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Copyist project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/copyist/blob/master/CODE_OF_CONDUCT.md).
