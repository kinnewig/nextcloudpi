#!/bin/bash

set -e

## BACKWARD FIXES ( for older images )

source /usr/local/etc/library.sh

# all images

# docker images only
[[ -f /.docker-image ]] && {
:
}

# for non docker images
[[ ! -f /.docker-image ]] && {
  # Update btrfs-sync
  wget -q https://raw.githubusercontent.com/nachoparker/btrfs-sync/master/btrfs-sync -O /usr/local/bin/btrfs-sync

  # work around dhcpcd Raspbian bug
  # https://lb.raspberrypi.org/forums/viewtopic.php?t=230779
  # https://github.com/nextcloud/nextcloudpi/issues/938
  test -f /usr/bin/raspi-config && {
    apt-get update
    apt-get install -y --no-install-recommends haveged
    systemctl enable haveged.service
  }
}

exit 0