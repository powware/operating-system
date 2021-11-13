cmake_minimum_required(VERSION 3.20.0)

set(CMAKE_CXX_STANDARD 20)

#https://stackoverflow.com/questions/53633705/cmake-the-c-compiler-is-not-able-to-compile-a-simple-test-program
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

project(operating-system ASM_NASM C CXX)

#add_library(bootloader OBJECT ${PROJECT_SOURCE_DIR}/src/bootstrap.asm
#                              ${PROJECT_SOURCE_DIR}/src/kernel.asm
#)
#
#target_compile_options(bootloader PRIVATE -felf64)


add_executable(operating-system ${PROJECT_SOURCE_DIR}/src/kernel/main.cpp)

target_compile_options(operating-system PRIVATE -Wall
                                                -Wextra
                                                -pedantic
                                                -Wpedantic
                                                -Werror
                                                -Wnon-virtual-dtor
                                                -Wshadow
                                                -Wold-style-cast
                                                -Wcast-align
                                                -Wunused
                                                -Woverloaded-virtual
                                                -Wformat=2
                                                -Wdouble-promotion
                                                -Wuseless-cast
                                                -Wnull-dereference
                                                -Wlogical-op
                                                -Wduplicated-branches
                                                -Wduplicated-cond
                                                -Wmisleading-indentation
                                                -Wconversion
                                                -Wsign-conversion
                                                -Wstrict-aliasing=2
                                                -O2
                                                -m64
                                                -mno-mmx
                                                -mno-sse
                                                -mno-sse2
                                                -mno-red-zone
                                                -mcmodel=large
                                                -ffreestanding
                                                -fno-exceptions
                                                -fno-rtti
)

target_link_options(operating-system PRIVATE -T ${PROJECT_SOURCE_DIR}/src/kernel/linker.ld
                                             -ffreestanding
                                             -nostdlib
                                             -lgcc
                                             -mno-red-zone
                                             -print-libgcc-file-name
)

target_link_libraries(operating-system PRIVATE bootloader)