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

ebegin "cloning sudoku to local"
git clone /home/git/sudoku o.repo
eend $?

ebegin "replaying sudoku into svn"
./git_replay o.repo s.rdb s.co/sudoku
eend $?

ebegin "adding more things"
(cd o.repo
    date > d1;
    mkdir test2;
    cp -va d1 test2/d1
    cg add d1 test2/d1

    cg commit -m "`date`"
)
eend $?

ebegin "replaying sudoku into svn (again)"
./git_replay o.repo s.rdb s.co/sudoku
eend $?

ebegin "replaying sudoku into svn (again)"
./git_replay o.repo s.rdb s.co/sudoku
eend $?

ebegin "adding more things"
(cd o.repo
    date > d2; cg add d2
    cg commit -m "`date`"
)
eend $?

ebegin "replaying sudoku into svn (again)"
./git_replay `pwd`/o.repo `pwd`/s.rdb `pwd`/s.co/sudoku
eend $?

exit 0 ## -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

ebegin "building actual svn subdirs";
./svn_builder s.repo s.co fight_daemon d20_rules_engine map_generator map_cgi_tests
eend $?

ebegin "replaying mapcgi into svn"
./git_replay /home/git/mapcgi s.rdb s.co/map_cgi_tests
eend $?

ebegin "replaying mapgen into svn"
./git_replay /home/git/mapgen s.rdb s.co/map_generator
eend $?

ebegin "replaying grd into svn"
./git_replay /home/git/grd s.rdb s.co/d20_rules_engine
eend $?

ebegin "replaying d20 into svn"
./git_replay /home/git/d20 s.rdb s.co/fight_daemon
eend $?
