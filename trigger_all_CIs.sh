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
	
	# get workflow run ID
	workflow_run_id=$(curl -s --fail -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $TOKEN" "https://api.github.com/repos/homalg-project/$repo/actions/runs?per_page=1&branch=master" | grep -m 1 '"id":' | grep -Po "\d+")
	
	# rerun the workflow run
	curl --fail -X POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $TOKEN" https://api.github.com/repos/homalg-project/$repo/actions/runs/$workflow_run_id/rerun
	
done <hosts
