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

VERSION=`gap --banner --quiet -A <( echo 'LoadPackage( "CompilerForCAP" ); Print( Last( GAPInfo.PackagesInfo.compilerforcap ).Version, "\n" ); QUIT_GAP();') | tr -d '\r'`

mkdir -p "/tmp/$DATE/pkg"

echo '(function()
  local name, package_info, pos;
    for name in RecNames( GAPInfo.PackagesInfo ) do
		if name = "io" then
			continue;
		fi;
        package_info := GAPInfo.PackagesInfo.(name);
        pos := PositionProperty( package_info, info -> StartsWith( info.InstallationPath, "../../" ) );
        if pos <> fail then
            SetPackagePath( name, package_info[pos].InstallationPath );
        fi;
    od;
end)();' > "/tmp/$DATE/gaprc"

cd "/tmp/$DATE/pkg"
git clone git@github.com:homalg-project/$PACKAGE.git
cd $PACKAGE

make doc
/usr/bin/gap -l "../../;~/.gap/;" -r tst/testall.g || echo "Changes found"

read -p "Please review all changes in \"file:///tmp/$DATE/pkg/$PACKAGE/\" and enter y to proceed. " -n 1
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
	echo "Create PR"
	git add -A
	git commit -m "Adjust to CompilerForCAP $VERSION"
	git push origin master:"CompilerForCAP-$VERSION"

	DATA=$(cat <<EOF
{
  "title": "Adjust to CompilerForCAP $VERSION",
  "head": "CompilerForCAP-$VERSION",
  "base": "master",
  "body": ""
}
EOF
)
	response=$(curl -s -S -H "Content-Type: application/json" -X POST --data "$DATA" "$API_URL" -H "Authorization: token $TOKEN")
else
	echo "No changes"
fi
