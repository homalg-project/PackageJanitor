#!/bin/bash

TOKEN=$(git config --get github.token || echo)
if [ "x$TOKEN" = x ] && [ -r ~/.github_shell_token ] ; then
    TOKEN=$(cat ~/.github_shell_token)
fi
if [ "x$TOKEN" = x ] ; then
    error "could not determine GitHub access token"
fi

while read repo; do
	
	echo $repo
	
	curl --fail -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $TOKEN" https://api.github.com/repos/homalg-project/$repo/actions/workflows/Tests.yml/dispatches -d '{"ref": "master"}'
	
done <hosts
