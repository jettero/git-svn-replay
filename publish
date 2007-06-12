#!/bin/bash
# : nb,v 1.12 2007/01/25 12:23:22 jettero Exp $
# vi:syntax=gentoo-init-d:

source /sbin/functions.sh
set -e; trap "eend 997" ERR

[ -d s.repo ] || exit 1

ebegin "fixing perms"
recuperms -t d -p 0755 -r s.repo
recuperms -t f -p 0644 -r s.repo
eend $?

ebegin "publishing"
rsyncp s.repo/ /home/svn/d20.combo/
eend $?

ebegin "trac-syncing"
sudo trac-admin /var/lib/trac/d20 resync
eend $?
