# kali-standalone-instruction

## Warning
The installation followed this instruction will finally drop into rescue-mode with root account locked away. I didn't figure out the reason, but there is an alternation. The fully encrypted bare-metal or standalone installation can be done by just setting up encrypted LVM partition. The efi will be installed right on the drive with kali linux, rather Windows or something irrelevant. And the "--removable" tag will be added to grub boot loader automatically.

## Instruction
This instruction was inspired by official document titled [Standalone Kali Linux 2021.4 Installation on a USB Drive, Fully Encrypted](https://www.kali.org/docs/usb/usb-standalone-encrypted/), and further modified or tested each time I reinstalled my kali system. The script install.sh is not a real executable shell script, but rather a record of what the READER should have done while 

- preparing target usb drive and table files;
- performing the actual installation;
- setting up inital ram and removable grub.

And this project will be maintained all the time until I give up Kali Linux some day, when is supposed to be non-existence!

## Materials
For completing installation of standalone system, and of course for your convenience, please set up three USB drives before everything that begins. Here is a checklist:

- USB drive burnt with Kali installer (for actual installation);
- USB drive burnt with Kali live system (for partitioning hard drive and setting up removable grub);
- USB drive that contains the code of this project (for duplicating table files and scripts).

If that's possible, please adopt a wifi-supported device as your playground. I don't expect your system to be installed without wifi firmwares.

## Issues
- The real-time kernel that's being named kali-6.8.11-rt doesn't work on desktop device. I don't know the reason but it happens to me, so I prefer standard kernel while using desktop. When I say "doesn't work", that means the system cannot load x windows directly, after which one could enter tty terminal and start the GUI manually by commanding "startx". All of this occurs since I have installed nvidia-driver. So, why is that?
