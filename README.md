# GooberOSx64
Rewritten version of GooberOSx86 into 64bit architecture.

it provides a minimal kernel and at the moment it just boots into the kernel in long mode.

# Verify: 

    sha256:42c3f60d9605e50dd4a41d8bf637f5724fe3cd034907a8e28bdbaea4dc2dfc1f

# How to install

* Grab magical USB
* Use MBR/BIOS (not UEFI, I hate UEFI)
* Use Rufus and write in DD mode (Because it doesn't use the iso9660 filesystem at the moment)

# How to use it in VM (virtual machine)

* Select Unknown 
* Select Unknown x64
* Use the ISO as the Bootable CD
