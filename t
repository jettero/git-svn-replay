#!/bin/bash
# : nb,v 1.12 2007/01/25 12:23:22 jettero Exp $
# vi:syntax=gentoo-init-d:

source /sbin/functions.sh
set -e; trap "eend 997" ERR

ebegin "cleaning"
./clean
eend $?

ebegin "building the svn export"
./svn_builder s.repo s.co mapcgi
eend $?

ebegin "cloning mapcgi to local"
git clone /home/git/mapcgi o.repo
eend $?

ebegin "replaying mapcgi into svn"
./git_replay git+ssh://corky/home/jettero/code/perl/git2svn/o.repo s.rdb s.co/mapcgi
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

ebegin "replaying mapcgi into svn (again)"
./git_replay o.repo s.rdb s.co/mapcgi
eend $?

ebegin "replaying mapcgi into svn (again)"
./git_replay o.repo s.rdb s.co/mapcgi
eend $?

ebegin "adding more things"
(cd o.repo
    date > d2; cg add d2
    cg commit -m "`date`"
)
eend $?

ebegin "replaying mapcgi into svn (again)"
./git_replay `pwd`/o.repo `pwd`/s.rdb `pwd`/s.co/mapcgi
eend $?
