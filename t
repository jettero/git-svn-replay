#!/bin/bash
# : nb,v 1.12 2007/01/25 12:23:22 jettero Exp $
# vi:syntax=gentoo-init-d:

source /sbin/functions.sh
set -e; trap "eend 997" ERR

ebegin "cleaning"
./clean
eend $?

ebegin "building the svn export"
./svn_builder s.repo s.co sudoku
eend $?

ebegin "building actual svn subdirs";
./svn_builder s.repo s.co fight_daemon d20_rules_engine map_generator map_cgi_tests
eend $?

ebegin "replaying sudoku into svn"
./git_replay /home/git/sudoku s.rdb s.co/sudoku
eend $?
