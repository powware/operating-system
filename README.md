# Operating System
x86-64
## Bootloader

### BIOS
The BIOS bootloader comes in two variants:
- Master Boot Record (MBR)
- GUID Partition Table (GPT)

BIOS bootloading is done through a two stage model. The first stage in the MBR (protective MBR for GPT) exist only to load the second stage, which in turn prepares everything for the kernel and loads it.

#### Stage 1
Stage 1 starts off by initializing stack, source and destination registers with default values, aswell as switching to TTY video mode. It then reloactes itself to address `0x600`. This is done, so the second stage can be loaded into the same starting address of `0x7C00` for chainloading. The next step is resetting the disk system, which is followed by checking whether the first MBR partion table entry of of type `0xEE`. This type indicates that the MBR is only protective and the drive is GPT partioned. Based on this result the execution differs for MBR and GPT partionied drives.

##### MBR
When the first entry is not of type `0xEE` the bootloader assumes the drive is MBR partioned and that the first MB is reserved for alignment purposes. This assumption is exploited by writing the second stage right after the MBR.
##### GPT
protective MBR

#### Stage 2
- [enable A20 Line](https://wiki.osdev.org/A20_Line):
    - try int 15 Method
    - try Keyboard Controller Method
    - try Fast A20 Method
- [setup GDT](https://wiki.osdev.org/GDT_Tutorial) [(GDT)](https://wiki.osdev.org/GDT)
- disable interrupts, including [NMI](https://wiki.osdev.org/Non_Maskable_Interrupt)
- [enter Protected Mode](https://wiki.osdev.org/Protected_mode)
- set up IDT
  - iretq for IDT entries
- set up Long Mode readying stuff (PAE, PML4, etc.) - Remember to set up the higher-half addressing!
- enter long mode
  - Disable paging
  - Set the PAE enable bit in CR4
  - Load CR3 with the physical address of the PML4 (Level 4 Page Map)
  - Enable long mode by setting the LME flag (bit 8) in MSR 0xC0000080 (aka EFER)
  - Enable paging
  - notify interrupt 15h from Real Mode with AX set to 0xEC00, and BL set to 1 for 32-bit Protected Mode, 2 for 64-bit Long Mode

### UEFI
not yet planned

## Sources:
- https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-3a-part-1-manual.pdf CHAPTER 9
- http://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf
- https://www.gnu.org/software/grub/manual/multiboot/multiboot.html
- https://en.wikipedia.org/wiki/GNU_GRUB
- https://en.wikipedia.org/wiki/INT_13H#EDD
- http://www.brokenthorn.com/Resources/OSDevIndex.html
- https://en.wikipedia.org/wiki/Master_boot_record
- https://wiki.osdev.org/Bootloader
- https://wiki.osdev.org/Rolling_Your_Own_Bootloader
- https://wiki.osdev.org/Real_Mode
- https://github.com/gmarino2048/64bit-os-tutorial/tree/master/Chapter%201
- https://wiki.osdev.org/Segmentation
- https://wiki.osdev.org/Task_State_Segment
- https://wiki.osdev.org/Paging
- https://wiki.osdev.org/A20_Line
- https://wiki.osdev.org/GDT
- https://wiki.osdev.org/GDT_Tutorial
- https://wiki.osdev.org/IVT
- https://wiki.osdev.org/Interrupt_Service_Routines
- https://wiki.osdev.org/Interrupt_Descriptor_Table
- https://wiki.osdev.org/Non_Maskable_Interrupt
- https://wiki.osdev.org/LDT
- https://wiki.osdev.org/TSS
- https://wiki.osdev.org/Protected_mode
- https://wiki.osdev.org/UEFI
- https://uefi.org/sites/default/files/resources/UEFI_Spec_2_9_2021_03_18.pdf
- https://www.reddit.com/r/osdev/comments/nwhoyr/any_good_beginner_64_bit_bootloader_guides/
- https://developer.amd.com/resources/developer-guides-manuals/
- https://wiki.osdev.org/X86-64
- https://wiki.osdev.org/POSIX-UEFI
- https://wiki.osdev.org/GNU-EFI
- https://wiki.osdev.org/UEFI_App_Bare_Bones
- https://www.amd.com/system/files/TechDocs/24592.pdf
- https://www.amd.com/system/files/TechDocs/24593.pdf

DataSheets:
- https://stanislavs.org/helppc/idx_interrupt.html

Testing:
MBR:
- bximage to create new hd image
- sudo losetup -f
- sudo losetup /dev/loopxx c.img
- sudo dd if=path/to/mbr of=/dev/loopxx bs=512
- sudo fdisk --protect-boot --cylinders 20 --heads 16 --sectors 63 -u /dev/loopxx
- n to create one partition
- w to write to file
- dd if=/path/to/bootloader of=/dev/loopxx bs=4096 skip=512 count=1MB-512 iflag=skip_bytes,count_bytes
GPT:

partition_type db "pow's bootloader" ; 27776F70-2073-6F62-6f74-6C6F61646572