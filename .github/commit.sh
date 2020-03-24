#!/bin/bash

# Validates the commit message according to conventional commits with the angular styleguide
conventional_commit_validator()
{
	declare -a const types=(build ci docs feat fix perf refactor test style)
	readonly const minLength=1
	readonly const maxLength=50
	readonly const unconventionalCommitErrorMsg="Invalid conventional commit message! Valid types are: ${types[@]}. The message length is maximum: $maxLength. Example: 'fix(config): add missing variable'"
	readonly const commitMsg=$(head -1 $1)

	regexp="^([A-Z0-9]+-[0-9]+\s)?(revert:\s)?("

	# Add all commit types to regex string
	for type in "${types[@]}"
	do
		regexp="${regexp}$type|"
	done

	echo $1
	echo $(head $1)
	echo $regexp

	# Support optional scope and add a minimum and maximum length to the regex string
	regexp="${regexp})(\(.+\))?:\s.{$minLength,$maxLength}$"

	if ! (echo $commitMsg | grep -Eq $regexp); then
		echo $unconventionalCommitErrorMsg
		exit 1
	fi
}

# Automatically prepending an issue key retrieved from the start of the current branch name to commit messages.
ticket_prefix()
{
	# check if commit is merge commit or a commit ammend
	if [[ $2 -eq "merge" ]] || [[ $2 -eq "commit" ]]; then
		exit
	fi

	ISSUE_KEY=$(git rev-parse --abbrev-ref HEAD | sed -nr 's,[a-z]+/([A-Z0-9]+-[0-9]+)-.+,\1,p')

	# only prepare commit message if pattern matched and issue key was found
	if [[ ! -z $ISSUE_KEY ]]; then
		sed -i.bak -e "1s/^/$ISSUE_KEY /" $1
		echo "oh noes"
	fi

}
