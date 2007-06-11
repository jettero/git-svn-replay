#!/bin/bash
# : nb,v 1.12 2007/01/25 12:23:22 jettero Exp $
# vi:syntax=gentoo-init-d:

source /sbin/functions.sh
set -e; trap "eend 997" ERR

git_repo=/home/git/sudoku
svn_name=s
svn_subd=sudoku

ebegin "cleaning"
./clean
eend $?

ebegin "building the svn export (and unused subdir)"
./svn_builder $svn_name.repo $svn_name.co unused
eend $?

ebegin "building actual svn subdir ($svn_subd)";
./svn_builder $svn_name.repo $svn_name.co $svn_subd
eend $?

ebegin "replaying git repo into svn"
./git_replay $git_repo $svn_name.co/$svn_subd $svn_name.rdb
eend $?
