#!/bin/sh

sudo qemu-kvm -m 768 \
    -boot d \
    -drive file=/bak/kvm/salix.qcow,cache=writeback \
    -cdrom /ntfs-d/ISO/salix64-openbox-14.1.iso -vnc :3

