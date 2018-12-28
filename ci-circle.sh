#!/bin/bash
# initialize parameters
# identify pull request and push
# prepare upload path, request url
SCANTIST_IMPORT_URL="https://api.scantist.io/ci-scan/"

show_project_info() {
  echo "CIRCLE_BRANCH $CIRCLE_BRANCH"
  echo "CIRCLE_SHA1 $CIRCLE_SHA1"
  echo "CIRCLE_USERNAME $CIRCLE_USERNAME"
  echo "CIRCLE_REPOSITORY_URL $CIRCLE_REPOSITORY_URL"
  echo "CIRCLE_PR_REPONAME $CIRCLE_PR_REPONAME"
  echo "CI_PULL_REQUEST $CI_PULL_REQUEST"
  echo "CIRCLE_PROJECT_USERNAME $CIRCLE_PROJECT_USERNAME"
  echo "CIRCLE_PROJECT_REPONAME $CIRCLE_PROJECT_REPONAME"
  echo "CIRCLE_PR_NUMBER $CIRCLE_PR_NUMBER"
  echo "=================project info====================="
}
echo "=================show_project_info================="
show_project_info

repo_name=$CIRCLE_PROJECT_USERNAME"/"$CIRCLE_PROJECT_REPONAME
commit_sha=$CIRCLE_SHA1
branch=$CIRCLE_BRANCH
build_time=$(date +"%s")
if [ -z ${CIRCLE_PR_NUMBER+x} ]; then pull_request="false"; else pull_request=$CIRCLE_PR_NUMBER; fi
cwd=$(pwd)

sudo apt-get install python-setuptools
sudo easy_install pip
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm git

if command -v python &>/dev/null; then
    pip freeze > requirements.txt
else
    echo Python is not installed
fi

curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

pyenv install 3.5.2

pyenv global 3.5.2


python <(curl -s https://scripts.scantist.com/TreeBuilder.py) $cwd $repo_name $commit_sha $branch $pull_request $build_time

#Log that the script download is complete and proceeding
echo "Uploading report at $SCANTIST_IMPORT_URL"

#Log the curl version used
curl --version

curl -g -v -f -X POST -d '@dependency-tree.json' -H 'Content-Type:application/json' -H 'Authorization: '"$SCANTISTTOKEN"'' "$SCANTIST_IMPORT_URL"

#Exit with the curl command's output status
exit $?
