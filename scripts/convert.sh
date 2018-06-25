#!/bin/bash

FORMAT=$1
BRANCH=`git rev-parse --abbrev-ref HEAD`
[ $BRANCH == HEAD ] && BRANCH=$TRAVIS_BRANCH
[ $TRAVIS_PULL_REQUEST == false ] || BRANCH=pr-$TRAVIS_PULL_REQUEST
git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git fetch origin ${BRANCH}-sentences
git checkout -b ${BRANCH}-sentences origin/${BRANCH}-sentences
BRANCH=${BRANCH}-$FORMAT

pip install -U 'semstr[amr]'
python -m semstr.convert *.pickle -o . -f $FORMAT --no-wikification --default-label="label" || exit 1
git fetch origin $BRANCH
if ! git checkout -b $BRANCH origin/$BRANCH; then
  git checkout --orphan $BRANCH
  git reset
fi
if [ $FORMAT == amr ]; then
  git add *.txt
else
  git add *.$FORMAT
fi

