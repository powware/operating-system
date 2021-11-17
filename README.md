[Bootloader](https://wiki.osdev.org/Bootloader):
  - [enable A20 Line](https://wiki.osdev.org/A20_Line):
    - try int 15 Method
    - try Keyboard Controller Method
    - try Fast A20 Method
  - [setup GDT](https://wiki.osdev.org/GDT_Tutorial) [(GDT)](https://wiki.osdev.org/GDT)
  - disable interrupts, including [NMI](https://wiki.osdev.org/Non_Maskable_Interrupt)
  - [enter Protected Mode](https://wiki.osdev.org/Protected_mode)
  - setup IDT:
      - iretq for IDT entries
  - enter Long Mode
Sources:
- http://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf
- https://www.gnu.org/software/grub/manual/multiboot/multiboot.html
- https://en.wikipedia.org/wiki/GNU_GRUB
- https://en.wikipedia.org/wiki/INT_13H#EDD
- http://www.brokenthorn.com/Resources/OSDevIndex.html
- https://en.wikipedia.org/wiki/Master_boot_record
- https://wiki.osdev.org/Bootloader
- https://wiki.osdev.org/Rolling_Your_Own_Bootloader
- https://wiki.osdev.org/Real_Mode
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

DataSheets:
- https://stanislavs.org/helppc/idx_interrupt.html