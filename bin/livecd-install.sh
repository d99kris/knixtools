#!/usr/bin/env bash

# livecd-install.sh v0.1
#
# Copyright (C) 2023 Kristofer Berggren
# All rights reserved.

# This script helps installing a Live CD/DVD to the first hard drive on the
# system. The intended use-case is to be able to quickly be able to set up a
# persistent installation VM, without going through the installer steps.
# The script is not intended for production VM installations of Linux distros,
# nor for physical systems as it uses BIOS boot instead of EFI.
#
# Supported distros: Void
#
# Usage:
#   bash <(curl -sL https://nope.se/li.sh) [OPTIONS]
#
# Options:
#   -d   debug mode, does not unmount installation partition after completion

exiterr() {
  >&2 echo "${1}, exiting."
  exit 1
}

warn() {
  >&2 echo "${1}"
}

user_check() {
  [[ "$(whoami)" == "root" ]] || exiterr "This script must be run as root"
  echo "WARNING: This script will erase all content on first hard drive."
  echo "It will not provide options to select which drive or partition to use."
  read -p "Proceed to install (yes/no)? "
  [[ "${REPLY}" == "yes" ]] || exiterr "User abort"
}

DEBUG=$([[ "${1}" == "-d" ]] && echo "1" || echo "0")
MNTDISK="/mnt/disk"
MNTROOT="/mnt/root"
ROOT="/"
USER="user"

install_void() {
  user_check
  [[ -x "$(command -v parted)" ]] || xbps-install -y parted || exiterr "Failed to install parted"
  [[ -x "$(command -v rsync)" ]] || xbps-install -y rsync || exiterr "Failed to install rsync"
  [[ -d "${MNTDISK}/dev" ]] && (umount ${MNTDISK}/dev || warn "Unmount /dev failed")
  [[ -d "${MNTDISK}/proc" ]] && (umount ${MNTDISK}/proc || warn "Unmount /proc failed")
  [[ -d "${MNTDISK}/sys" ]] && (umount ${MNTDISK}/sys || warn "Unmount /sys failed")
  [[ -d "${MNTDISK}" ]] && (umount ${MNTDISK} || exiterr "Unmount ${MNTDISK} failed")
  [[ -d "${MNTDISK}" ]] && (rmdir ${MNTDISK} || exiterr "Delete mount point ${MNTDISK} failed")
  [[ -d "${MNTROOT}" ]] && (umount ${MNTROOT} || exiterr "Unmount ${MNTROOT} failed")
  [[ -d "${MNTROOT}" ]] && (rmdir ${MNTROOT} || exiterr "Delete mount point ${MNTROOT} failed")
  DRIVEINFO=$(lsblk -io TYPE,KNAME,SIZE | grep "^disk" | sort -k3,3hr | head -1)
  [[ "${DRIVEINFO}" != "" ]] || exiterr "No drive found"
  DEVICE="/dev/$(echo "${DRIVEINFO}" | awk '{print $2}')"
  stat ${DEVICE} &> /dev/null || exiterr "Device ${DEVICE} does not exist"
  parted -s ${DEVICE} mklabel msdos || exiterr "Create partition table failed"
  parted -s ${DEVICE} mkpart primary ext4 0% 100% || exiterr "Create partition failed"
  PARTITION="${DEVICE}1"
  yes | mkfs.ext4 ${PARTITION} || exiterr "Formatting partition failed"
  (mkdir ${MNTDISK} && mount ${PARTITION} ${MNTDISK}) || exiterr "Mount ${PARTITION} failed"
  (mkdir ${MNTROOT} && mount ${ROOT} ${MNTROOT} -o bind) || exiterr "Mount ${ROOT} failed"

  rsync -a --info=progress2 --no-i-r ${MNTROOT}/ ${MNTDISK}/
  # rsync < 3.1 may need: rsync -aP ${MNTROOT}/ ${MNTDISK}/

  unset UUID
  eval $(blkid | grep "^${PARTITION}" | awk '{print $2}')
  echo "UUID=${UUID}	/	ext4	defaults	0	2" >> ${MNTDISK}/etc/fstab
  grub-install --root-directory=${MNTDISK} ${DEVICE}

  mount --bind /dev ${MNTDISK}/dev || exiterr "Mount /dev failed"
  mount --bind /proc ${MNTDISK}/proc || exiterr "Mount /proc failed"
  mount --bind /sys ${MNTDISK}/sys || exiterr "Mount /sys failed"

  chroot ${MNTDISK} update-grub || exiterr "Update Grub failed"

  chroot ${MNTDISK} useradd --create-home ${USER} || exiterr "User add failed"
  chroot ${MNTDISK} usermod --append --groups wheel ${USER} || exiterr "User mod failed"
  echo "Set password for '${USER}':"
  chroot ${MNTDISK} passwd ${USER} || exiterr "User password set failed"
  chroot ${MNTDISK} sh -c "echo \"%wheel ALL=(ALL:ALL) NOPASSWD: ALL\" >> /etc/sudoers" || exiterr "Add to sudoers failed"

  if [[ "${DEBUG}" == "0" ]]; then
    [[ -d "${MNTDISK}/dev" ]] && (umount ${MNTDISK}/dev || exiterr "Unmount /dev failed")
    [[ -d "${MNTDISK}/proc" ]] && (umount ${MNTDISK}/proc || exiterr "Unmount /proc failed")
    [[ -d "${MNTDISK}/sys" ]] && (umount ${MNTDISK}/sys || exiterr "Unmount /sys failed")
    [[ -d "${MNTDISK}" ]] && (umount ${MNTDISK} || exiterr "Unmount ${MNTDISK} failed")
    [[ -d "${MNTDISK}" ]] && (rmdir ${MNTDISK} || exiterr "Delete mount point ${MNTDISK} failed")
    [[ -d "${MNTROOT}" ]] && (umount ${MNTROOT} || exiterr "Unmount ${MNTROOT} failed")
    [[ -d "${MNTROOT}" ]] && (rmdir ${MNTROOT} || exiterr "Delete mount point ${MNTROOT} failed")
  fi
}

unset NAME
eval $(grep "^NAME=" /etc/os-release 2> /dev/null)
if [[ "${NAME}" == "Void" ]]; then
  install_void
else
  exiterr "unsupported linux distro (${NAME})"
fi

echo ""
echo "Completed successfully."
echo ""
echo "Call 'poweroff', eject installation medium and start again."
echo ""
exit 0

