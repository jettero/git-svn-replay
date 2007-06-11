#!/bin/bash
# : nb,v 1.12 2007/01/25 12:23:22 jettero Exp $
# vi:syntax=gentoo-init-d:

source /sbin/functions.sh
set -e; trap "eend 997" ERR

gdir=gitdiffdumper
ldir=g

ebegin "cleaning"
eindent
./clean
x=$?
eoutdent
eend $x

ebegin "dumping this repo"
./diff_dumper /home/git/$gdir/ $ldir.diffs
eend $?

ebegin "building the svn export"
./svn_builder $ldir.diffs $ldir.repo $ldir.co
eend $?
