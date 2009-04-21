#!/bin/bash

set -e; trap "echo ERROR detected, exiting; exit 1" ERR

git clean -dfx
./svn_builder s.repo s.co git_svn_replay

git clone /home/git/git_svn_replay o.repo
./git_replay o.repo s.rdb s.co/git_svn_replay

