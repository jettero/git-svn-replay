#!/bin/bash

set -e; trap "echo ERROR detected, exiting; exit 1" ERR

# should be able to run this over and over without needing to git clean -dfx

./svn_builder s.repo s.co gsr_master
./svn_builder s.repo s.co gsr_public

./git_replay -d s.rdb /home/git/git_svn_replay s.co/gsr_master
./git_replay -d s.rdb git@github.com:jettero/git_svn_replay.git s.co/gsr_public

