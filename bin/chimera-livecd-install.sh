#!/usr/bin/env bash

# chimera-livecd-install.sh v0.1
#
# Copyright (C) 2023 Kristofer Berggren
# All rights reserved.

# This script helps installing Chimera Linux from a Live CD/DVD.
# It's intended to be used to quickly set up test VMs, not for
# proper production systems.

# Usage:
# su root  # pass: chimera
# apk add bash curl
# bash <(curl -sL https://nope.se/cli.sh)

exiterr() {
  >&2 echo "${1}, exiting."
  exit 1
}

warn() {
  >&2 echo "${1}"
}

DEBUG=$([[ "${1}" == "-d" ]] && echo "1" || echo "0")
MNTROOT="/media/root"
MNTEFI="${MNTROOT}/boot/efi"
USER="user"
PASS="pass"

user_check() {
  [[ "$(whoami)" == "root" ]] || exiterr "This script must be run as root"
  echo "WARNING: This script will erase all content on first hard drive."
  echo "It will not provide options to select which drive or partition to use."
  read -p "Proceed to install (y/n)? "
  [[ "${REPLY}" == "y" ]] || exiterr "User abort"
  read -p "Create new user (${USER}): "
  [[ "${REPLY}" != "" ]] && USER="${REPLY}"
  read -s -p "Set user password (${PASS}): "
  [[ "${REPLY}" != "" ]] && PASS="${REPLY}"
  echo ""
}

distro_check() {
  if [[ "${DISTRO}" != "Chimera" ]]; then
    exiterr "unsupported linux distro (${NAME})"
  fi
}

setup_deps() {
  if [[ "${DISTRO}" == "Chimera" ]]; then
    true
  fi
}

cleanup_mounts() {
  # Todo: Cleanup /media/root/dev
  [[ -d "${MNTEFI}" ]] && (umount ${MNTEFI} || warn "Unmount ${MNTEFI} failed")
  [[ -d "${MNTEFI}" ]] && (rmdir ${MNTEFI} || warn "Delete mount point ${MNTEFI} failed")
  [[ -d "${MNTROOT}" ]] && (umount ${MNTROOT} || exiterr "Unmount ${MNTROOT} failed")
  [[ -d "${MNTROOT}" ]] && (rmdir ${MNTROOT} || exiterr "Delete mount point ${MNTROOT} failed")
}

perform_install() {
  # Clean up existing mounts (to support retry running script)
  cleanup_mounts
  
  # Set up hard drive
  DRIVEINFO=$(lsblk -io TYPE,KNAME,SIZE | grep "^disk" | sort -k3,3hr | head -1)
  [[ "${DRIVEINFO}" != "" ]] || exiterr "No drive found"
  DEVICE="/dev/$(echo "${DRIVEINFO}" | awk '{print $2}')"
  stat ${DEVICE} &> /dev/null || exiterr "Device ${DEVICE} does not exist"
  wipefs -a ${DEVICE} || exiterr "Wipe ${DEVICE} failed"

  EFISIZE="100M"
  RAMGB="$(free -g | grep "^Mem:" | awk '{print $2}')"
  if [[ "${RAMGB}" -gt "0" ]] 2> /dev/null; then
    SWAPSIZE="${RAMGB}G"
  else
    SWAPSIZE="4G"
  fi
  
  sfdisk ${DEVICE} <<EOF || exiterr "Partitioning ${DEVICE} failed"
label: gpt
name=esp, size=${EFISIZE}, type="EFI System"
name=swap, size=${SWAPSIZE}, type="Linux swap"
name=root
EOF

  DEVEFI="${DEVICE}1"
  DEVSWAP="${DEVICE}2"
  DEVROOT="${DEVICE}3"
  yes | mkfs.vfat ${DEVEFI} || exiterr "Formatting ${DEVEFI} failed"
  yes | mkswap ${DEVSWAP} || exiterr "Formatting ${DEVSWAP} failed"
  yes | mkfs.ext4 ${DEVROOT} || exiterr "Formatting ${DEVROOT} failed"

  (mkdir -p ${MNTROOT} && mount ${DEVROOT} ${MNTROOT}) || exiterr "Mount ${DEVROOT} failed"
  (mkdir -p ${MNTEFI} && mount ${DEVEFI} ${MNTEFI}) || exiterr "Mount ${DEVEFI} failed"

  chmod 755 ${MNTROOT} || exiterr "chmod ${MNTROOT} failed"
  chimera-bootstrap -l ${MNTROOT} || exiterr "Bootstrap ${MNTROOT} failed"
  CHROOT="chimera-chroot ${MNTROOT}"
  ${CHROOT} apk update --no-interactive || exiterr "apk update failed"

  ${CHROOT} apk upgrade --available --no-interactive || exiterr "apk upgrade failed"
  ${CHROOT} apk fix --no-interactive || exiterr "apk fix failed"
  ${CHROOT} apk add linux-lts --no-interactive || exiterr "apk add linux-lts failed"
  if [[ "$(uname -m)" == "aarch64" ]]; then
    GRUBPKG="grub-arm64-efi"
  else
    GRUBPKG="grub-$(uname -m)-efi"
  fi
  ${CHROOT} apk add ${GRUBPKG} --no-interactive || exiterr "apk add ${GRUBPKG} failed"

  ${CHROOT} swapon ${DEVSWAP} || exiterr "swapon failed"
  ${CHROOT} genfstab -t PARTLABEL / > /etc/fstab || exiterr "genfstab failed"
  yes "${PASS}" | ${CHROOT} passwd root || exiterr "Setting root passwd failed"
  ${CHROOT} useradd ${USER} || exiterr "Adding user ${USER} failed"
  yes "${PASS}" | ${CHROOT} passwd ${USER} || exiterr "Setting ${USER} passwd failed"
  ${CHROOT} usermod -a -G wheel ${USER} || exiterr "Adding ${USER} group failed"
  ${CHROOT} echo host > /etc/hostname || exiterr "Setting hostname failed"
  ${CHROOT} ln -sf ../usr/share/zoneinfo/Asia/Singapore /etc/localtime || exiterr "Timezone failed"
  ${CHROOT} dinitctl -o enable gdm || exiterr "Enabling gdm failed"
  ${CHROOT} dinitctl -o enable chrony || exiterr "Enabling chrony failed"
  ${CHROOT} dinitctl -o enable networkmanager || exiterr "Enabling networkmanager failed"
  ${CHROOT} update-initramfs -c -k all || exiterr "update-initramfs failed"
  ${CHROOT} mount -t efivarfs efivarfs /sys/firmware/efi/efivars || exiterr "mount efivarfs failed"
  ${CHROOT} grub-install --efi-directory=/boot/efi || exiterr "Grub install failed"
  ${CHROOT} update-grub || exiterr "Update grub failed"
}

unset NAME
eval $(grep "^NAME=" /etc/os-release 2> /dev/null)
DISTRO="${NAME}"

distro_check
user_check
setup_deps
perform_install

echo ""
echo "Completed successfully."
echo ""
echo "Call 'poweroff', eject installation medium and start again."
echo ""
exit 0
