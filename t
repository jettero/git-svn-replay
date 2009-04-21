#!/bin/bash

set -e; trap "echo ERROR detected, exiting; exit 1" ERR

# should be able to run this over and over without needing to git clean -dfx

./svn_builder s.repo s.co git_svn_replay
./svn_builder s.repo s.co gsr_public

./git_replay -d s.rdb /home/git/git_svn_replay s.co/git_svn_replay
./git_replay -d s.rdb git@github.com:jettero/git_svn_replay.git s.co/git_svn_replay

