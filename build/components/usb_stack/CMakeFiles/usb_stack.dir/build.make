# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.19

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Disable VCS-based implicit rules.
% : %,v


# Disable VCS-based implicit rules.
% : RCS/%


# Disable VCS-based implicit rules.
% : RCS/%,v


# Disable VCS-based implicit rules.
% : SCCS/s.%


# Disable VCS-based implicit rules.
% : s.%


.SUFFIXES: .hpux_make_needs_suffix_list


# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake-3.19.3-Linux-x86_64/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake-3.19.3-Linux-x86_64/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/zp/develop/BL702/RV-Debugger-BL702

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/zp/develop/BL702/RV-Debugger-BL702/build

# Include any dependencies generated for this target.
include components/usb_stack/CMakeFiles/usb_stack.dir/depend.make

# Include the progress variables for this target.
include components/usb_stack/CMakeFiles/usb_stack.dir/progress.make

# Include the compile flags for this target's objects.
include components/usb_stack/CMakeFiles/usb_stack.dir/flags.make

components/usb_stack/CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.obj: components/usb_stack/CMakeFiles/usb_stack.dir/flags.make
components/usb_stack/CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.obj: ../components/usb_stack/class/audio/usbd_audio.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zp/develop/BL702/RV-Debugger-BL702/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object components/usb_stack/CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.obj"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.obj -c /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/audio/usbd_audio.c

components/usb_stack/CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.i"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/audio/usbd_audio.c > CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.i

components/usb_stack/CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.s"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/audio/usbd_audio.c -o CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.s

components/usb_stack/CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.obj: components/usb_stack/CMakeFiles/usb_stack.dir/flags.make
components/usb_stack/CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.obj: ../components/usb_stack/class/cdc/usbd_cdc.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zp/develop/BL702/RV-Debugger-BL702/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building C object components/usb_stack/CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.obj"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.obj -c /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/cdc/usbd_cdc.c

components/usb_stack/CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.i"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/cdc/usbd_cdc.c > CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.i

components/usb_stack/CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.s"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/cdc/usbd_cdc.c -o CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.s

components/usb_stack/CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.obj: components/usb_stack/CMakeFiles/usb_stack.dir/flags.make
components/usb_stack/CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.obj: ../components/usb_stack/class/hid/usbd_hid.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zp/develop/BL702/RV-Debugger-BL702/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Building C object components/usb_stack/CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.obj"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.obj -c /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/hid/usbd_hid.c

components/usb_stack/CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.i"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/hid/usbd_hid.c > CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.i

components/usb_stack/CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.s"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/hid/usbd_hid.c -o CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.s

components/usb_stack/CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.obj: components/usb_stack/CMakeFiles/usb_stack.dir/flags.make
components/usb_stack/CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.obj: ../components/usb_stack/class/msc/usbd_msc.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zp/develop/BL702/RV-Debugger-BL702/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_4) "Building C object components/usb_stack/CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.obj"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.obj -c /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/msc/usbd_msc.c

components/usb_stack/CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.i"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/msc/usbd_msc.c > CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.i

components/usb_stack/CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.s"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/msc/usbd_msc.c -o CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.s

components/usb_stack/CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.obj: components/usb_stack/CMakeFiles/usb_stack.dir/flags.make
components/usb_stack/CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.obj: ../components/usb_stack/class/vendor/usbd_ftdi.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zp/develop/BL702/RV-Debugger-BL702/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_5) "Building C object components/usb_stack/CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.obj"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.obj -c /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/vendor/usbd_ftdi.c

components/usb_stack/CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.i"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/vendor/usbd_ftdi.c > CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.i

components/usb_stack/CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.s"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/vendor/usbd_ftdi.c -o CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.s

components/usb_stack/CMakeFiles/usb_stack.dir/class/video/usbd_video.c.obj: components/usb_stack/CMakeFiles/usb_stack.dir/flags.make
components/usb_stack/CMakeFiles/usb_stack.dir/class/video/usbd_video.c.obj: ../components/usb_stack/class/video/usbd_video.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zp/develop/BL702/RV-Debugger-BL702/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_6) "Building C object components/usb_stack/CMakeFiles/usb_stack.dir/class/video/usbd_video.c.obj"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/usb_stack.dir/class/video/usbd_video.c.obj -c /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/video/usbd_video.c

components/usb_stack/CMakeFiles/usb_stack.dir/class/video/usbd_video.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/usb_stack.dir/class/video/usbd_video.c.i"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/video/usbd_video.c > CMakeFiles/usb_stack.dir/class/video/usbd_video.c.i

components/usb_stack/CMakeFiles/usb_stack.dir/class/video/usbd_video.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/usb_stack.dir/class/video/usbd_video.c.s"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/video/usbd_video.c -o CMakeFiles/usb_stack.dir/class/video/usbd_video.c.s

components/usb_stack/CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.obj: components/usb_stack/CMakeFiles/usb_stack.dir/flags.make
components/usb_stack/CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.obj: ../components/usb_stack/class/webusb/usbd_webusb.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zp/develop/BL702/RV-Debugger-BL702/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_7) "Building C object components/usb_stack/CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.obj"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.obj -c /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/webusb/usbd_webusb.c

components/usb_stack/CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.i"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/webusb/usbd_webusb.c > CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.i

components/usb_stack/CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.s"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/webusb/usbd_webusb.c -o CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.s

components/usb_stack/CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.obj: components/usb_stack/CMakeFiles/usb_stack.dir/flags.make
components/usb_stack/CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.obj: ../components/usb_stack/class/winusb/usbd_winusb.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zp/develop/BL702/RV-Debugger-BL702/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_8) "Building C object components/usb_stack/CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.obj"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.obj -c /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/winusb/usbd_winusb.c

components/usb_stack/CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.i"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/winusb/usbd_winusb.c > CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.i

components/usb_stack/CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.s"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/class/winusb/usbd_winusb.c -o CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.s

components/usb_stack/CMakeFiles/usb_stack.dir/core/usbd_core.c.obj: components/usb_stack/CMakeFiles/usb_stack.dir/flags.make
components/usb_stack/CMakeFiles/usb_stack.dir/core/usbd_core.c.obj: ../components/usb_stack/core/usbd_core.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/zp/develop/BL702/RV-Debugger-BL702/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_9) "Building C object components/usb_stack/CMakeFiles/usb_stack.dir/core/usbd_core.c.obj"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/usb_stack.dir/core/usbd_core.c.obj -c /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/core/usbd_core.c

components/usb_stack/CMakeFiles/usb_stack.dir/core/usbd_core.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/usb_stack.dir/core/usbd_core.c.i"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/core/usbd_core.c > CMakeFiles/usb_stack.dir/core/usbd_core.c.i

components/usb_stack/CMakeFiles/usb_stack.dir/core/usbd_core.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/usb_stack.dir/core/usbd_core.c.s"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && /usr/bin/riscv64-elf-20210120/bin/riscv64-unknown-elf-gcc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack/core/usbd_core.c -o CMakeFiles/usb_stack.dir/core/usbd_core.c.s

# Object files for target usb_stack
usb_stack_OBJECTS = \
"CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.obj" \
"CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.obj" \
"CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.obj" \
"CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.obj" \
"CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.obj" \
"CMakeFiles/usb_stack.dir/class/video/usbd_video.c.obj" \
"CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.obj" \
"CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.obj" \
"CMakeFiles/usb_stack.dir/core/usbd_core.c.obj"

# External object files for target usb_stack
usb_stack_EXTERNAL_OBJECTS =

components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/class/audio/usbd_audio.c.obj
components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/class/cdc/usbd_cdc.c.obj
components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/class/hid/usbd_hid.c.obj
components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/class/msc/usbd_msc.c.obj
components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/class/vendor/usbd_ftdi.c.obj
components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/class/video/usbd_video.c.obj
components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/class/webusb/usbd_webusb.c.obj
components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/class/winusb/usbd_winusb.c.obj
components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/core/usbd_core.c.obj
components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/build.make
components/usb_stack/libusb_stack.a: components/usb_stack/CMakeFiles/usb_stack.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/zp/develop/BL702/RV-Debugger-BL702/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_10) "Linking C static library libusb_stack.a"
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && $(CMAKE_COMMAND) -P CMakeFiles/usb_stack.dir/cmake_clean_target.cmake
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/usb_stack.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
components/usb_stack/CMakeFiles/usb_stack.dir/build: components/usb_stack/libusb_stack.a

.PHONY : components/usb_stack/CMakeFiles/usb_stack.dir/build

components/usb_stack/CMakeFiles/usb_stack.dir/clean:
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack && $(CMAKE_COMMAND) -P CMakeFiles/usb_stack.dir/cmake_clean.cmake
.PHONY : components/usb_stack/CMakeFiles/usb_stack.dir/clean

components/usb_stack/CMakeFiles/usb_stack.dir/depend:
	cd /home/zp/develop/BL702/RV-Debugger-BL702/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/zp/develop/BL702/RV-Debugger-BL702 /home/zp/develop/BL702/RV-Debugger-BL702/components/usb_stack /home/zp/develop/BL702/RV-Debugger-BL702/build /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack /home/zp/develop/BL702/RV-Debugger-BL702/build/components/usb_stack/CMakeFiles/usb_stack.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : components/usb_stack/CMakeFiles/usb_stack.dir/depend
