# Copyist
This application is a tool that can parse a file written in markdown and generate multiple Github isuue tickets at once.

The word 'Copyist' means 'Hikko (筆耕)' in Japanese.

## How to use
### step0. Installation
- `$ gem install copyist`

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
1. `$ copyist job path/to/markdown_file.md`


## Required or Optional Settings (to ENV or .env)
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

#### ENVFILE_PATH
ENV-related settings can be specified in a file.
Enter the path in the environment variable ENVFILE_PATH.


example)
```
$ export ENVFILE_PATH=.env
```

## Experimental Feature
Implemented a feature to generate JIRA child issues.
(Because the team I belong to switched from GIthub to JIRA)

By setting the `JIRA_PARENT_PROJECT_IDENTIFIRE` key to the prepared markdown, you can create a ticket for a child issue that is connected to an already existing parent issue.

Please check the implementation for details.


## Development

## Contributing

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Copyist project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/copyist/blob/master/CODE_OF_CONDUCT.md).
