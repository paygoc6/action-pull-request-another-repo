#!/bin/sh

set -e
set -x

if [ -z "$INPUT_SOURCE_FOLDER" ]
then
  echo "Source folder must be defined"
  return -1
fi

if [ -z $INPUT_PR_TITLE]
then
    echo "pr_title must be defined"
    return -1
fi


if [ -z $INPUT_COMMIT_MSG]
then
    echo "commit_msg must be defined"
    return -1
fi

if [ $INPUT_DESTINATION_HEAD_BRANCH == "main" ] || [ $INPUT_DESTINATION_HEAD_BRANCH == "master"]
then
  echo "Destination head branch cannot be 'main' nor 'master'"
  return -1
fi

if [ -z "$INPUT_PULL_REQUEST_REVIEWERS" ]
then
  PULL_REQUEST_REVIEWERS=$INPUT_PULL_REQUEST_REVIEWERS
else
  PULL_REQUEST_REVIEWERS='-r '$INPUT_PULL_REQUEST_REVIEWERS
fi

CLONE_DIR=$(mktemp -d)

echo "Setting git variables"
export GITHUB_TOKEN=$API_TOKEN_GITHUB
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"

echo "Cloning destination git repository"
git clone "https://$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"

echo "Creating folder & cd into their"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER/
cd "$CLONE_DIR"


echo "Checking if branch already exists"
git fetch -a
if git show-ref "$INPUT_DESTINATION_HEAD_BRANCH"; 
then
    git checkout "$INPUT_DESTINATION_HEAD_BRANCH"
else 
    git checkout -b "$INPUT_DESTINATION_HEAD_BRANCH"
fi

echo "Copying content into destination folder"
rsync -a --delete "$INPUT_SOURCE_FOLDER" "$CLONE_DIR/$INPUT_DESTINATION_FOLDER/"
git add .

if git status | grep -q "Changes to be committed"
then
  git commit --message "$INPUT_COMMIT_MSG"

  echo "Pushing git commit"
  git push -u origin HEAD:$INPUT_DESTINATION_HEAD_BRANCH
  echo "Creating a pull request"
  gh pr create -t "$INPUT_PR_TITLE" \
               -b "Update from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA" \
               -B $INPUT_DESTINATION_BASE_BRANCH \
               -H $INPUT_DESTINATION_HEAD_BRANCH \
                  $PULL_REQUEST_REVIEWERS
else
  echo "No changes detected"
fi
