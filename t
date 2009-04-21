#!/bin/bash

set -e; trap "echo ERROR detected, exiting; exit 1" ERR

git clean -dfx
./svn_builder s.repo s.co git_svn_replay

