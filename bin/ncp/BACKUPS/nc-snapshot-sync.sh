#!/bin/bash

# Sync Nextcloud BTRFS snapshots
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/02/13/nextcloud-ready-raspberry-pi-image/
#


install()
{
  apt-get update
  apt-get install -y --no-install-recommends pv:arm64 openssh-client:arm64
  wget https://raw.githubusercontent.com/nachoparker/btrfs-sync/master/btrfs-sync -O /usr/local/bin/btrfs-sync
  chmod +x /usr/local/bin/btrfs-sync
  if ! [[ -f /root/.ssh/id_rsa ]]; then ssh-keygen -N "" -f /root/.ssh/id_rsa; fi
}

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    rm -f /etc/cron.d/ncp-snapsync-auto
    service cron restart
    echo "snapshot sync disabled"
    return 0
  }

  # checks
  [[ -d "$SNAPDIR" ]] || { echo "$SNAPDIR does not exist"; return 1; }

  [[ "$DESTINATION" =~ : ]] && {
    local NET="$( sed 's|:.*||' <<<"$DESTINATION" )"
    local DST="$( sed 's|.*:||' <<<"$DESTINATION" )"
    local SSH=( ssh -o "BatchMode=yes" "$NET" )
    ${SSH[@]} : || { echo "SSH non-interactive not properly configured"; return 1; }
  } || DST="$DESTINATION"
  [[ "$( ${SSH[@]} stat -fc%T "$DST" )" != "btrfs" ]] && {
    echo "$DESTINATION is not in a BTRFS filesystem"
    return 1
  }

  [[ "$COMPRESSION" == "yes" ]] && ZIP="-z"

  echo "30  4  */${SYNCDAYS}  *  *  root  /usr/local/bin/btrfs-sync -qd $ZIP \"$SNAPDIR\" \"$DESTINATION\"" > /etc/cron.d/ncp-snapsync-auto
  chmod 644 /etc/cron.d/ncp-snapsync-auto
  service cron restart
  echo "snapshot sync enabled"
}

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA

