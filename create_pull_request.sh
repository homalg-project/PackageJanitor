#!/bin/bash

set -e
set -u

SCRIPT=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPT)

PACKAGE="$1"

TOKEN=$(git config --get github.token || echo)
if [ "x$TOKEN" = x ] && [ -r ~/.github_shell_token ] ; then
    TOKEN=$(cat ~/.github_shell_token)
fi
if [ "x$TOKEN" = x ] ; then
    error "could not determine GitHub access token"
fi

API_URL=https://api.github.com/repos/homalg-project/$PACKAGE/pulls

DATE=$(date +%s)

mkdir "/tmp/$DATE"
cd "/tmp/$DATE"
git clone git@github.com:homalg-project/$PACKAGE.git
cd $PACKAGE
git worktree add gh-pages gh-pages
cd "$SCRIPTPATH"
./apply -l $PACKAGE -e pkg_dir="/tmp/$DATE/"

read -p "Please review all changes in \"file:///tmp/$DATE/$PACKAGE/\" and \"file:///tmp/$DATE/$PACKAGE/gh-pages\" and enter y to proceed. " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

cd "/tmp/$DATE/$PACKAGE"
cd gh-pages
if [ -n "$(git status --porcelain)" ]; then
	echo "Create PR for gh-pages"
	git add -A
	git commit -m "Apply PackageJanitor"
	git push origin gh-pages:"PackageJanitor-gh-pages-$DATE"

	DATA=$(cat <<EOF
{
  "title": "Apply PackageJanitor to gh-pages",
  "head": "PackageJanitor-gh-pages-$DATE",
  "base": "gh-pages"
}
EOF
)
	response=$(curl -s -S -H "Content-Type: application/json" -X POST --data "$DATA" "$API_URL" -H "Authorization: token $TOKEN")
else
	echo "No changes to gh-pages"
fi
cd ..
if [ -n "$(git status --porcelain)" ]; then
	echo "Create PR for master"
	git add -A
	git commit -m "Apply PackageJanitor"
	git push origin master:"PackageJanitor-$DATE"

	DATA=$(cat <<EOF
{
  "title": "Apply PackageJanitor",
  "head": "PackageJanitor-$DATE",
  "base": "master",
  "body": "If there is a PR 'Apply PackageJanitor to gh-pages', please merge both PRs together."
}
EOF
)
	response=$(curl -s -S -H "Content-Type: application/json" -X POST --data "$DATA" "$API_URL" -H "Authorization: token $TOKEN")
else
	echo "No changes to master"
fi
