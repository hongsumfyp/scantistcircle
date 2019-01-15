#!/bin/bash
bamboo_SCANTIST_IMPORT_URL="https://api-staging.scantist.io/ci-scan/"
bamboo_SCANTISTTOKEN="ba5e486c-2fb8-4dfc-9d61-73640cc825c4"
if [ -z ${bamboo_repository_git_username+x} ]; then repo_name=${bamboo_repository_name}; else repo_name=${bamboo_repository_git_username}"/"${bamboo_repository_name}; fi
if [ -z ${bamboo_repository_revision_number+x} ]; then commit_sha="na"; else commit_sha=${bamboo_repository_revision_number}; fi
if [ -z ${bamboo_repository_branch_name+x} ]; then branch="na"; else branch=${bamboo_repository_branch_name}; fi
build_time=$(date +"%s")
# default value
pull_request="false"
cwd=$(pwd)

echo $repo_name
echo $commit_sha
echo $branch
echo $pull_request
echo $build_time
echo $cwd

#Log the curl version used
curl --version
curl -s https://scripts.scantist.com/staging/scantist-bom-detect.jar --output scantist-bom-detect.jar

java -jar scantist-bom-detect.jar -repo_name $repo_name -commit_sha $commit_sha -branch $branch -pull_request $pull_request -working_dir $cwd -build_time $build_time

#Log that the script download is complete and proceeding
echo "Uploading report at ${bamboo_SCANTIST_IMPORT_URL}"

curl -g -v -f -X POST -d '@dependency-tree.json' -H 'Cache-Control: no-cache' -H 'Content-Type:application/json' -H 'Authorization: '"${bamboo_SCANTISTTOKEN}"'' "${bamboo_SCANTIST_IMPORT_URL}"


rm -f scantist-bom-detect.jar
rm -f dependency-tree.json
rm -f scantistDepGraph.py

#Exit with the curl command's output status
exit $?
