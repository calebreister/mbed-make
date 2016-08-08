[!Certified to work on my machine](http://jcooney.net/img/worksonmymachine_logo_small.png)

### Introduction
This project is designed as a template for a multi-directory ARM makefile project that also links to the [mbed](https://developer.mbed.org/users/mbed_official/code/mbed/) and [mbed-rtos](https://developer.mbed.org/users/mbed_official/code/mbed-rtos/) libraries. I tried to keep the build system fairly simple, but at the same time I wanted to keep everything neatly organized. The table below explains the contents of each top-level folder.

Folder  | Description
--------|-------------
debug   | Debugging symbols and binaries from the compiled project
lib     | Libraries that will be linked in or compiled as part of the project
obj     | Destination for all intermediate object files
release | Binaries compiled without debugging symbols, size-optimized by default
scripts | Scripts used during the build process (see below)
src     | Source code

### Obtaining copies of mbed and mbed-rtos
I have not included copies of mbed and mbed-rtos with this project directly because up-to-date versions are easily obtainable from the mbed website. The links above provide access to the downloads. If you have an mbed account (which is free), you can download mbed as a Mercurial repository, which can be more convenient in some cases. Otherwise, anyone can download the zip or gz files for the current versions.

### Using the Makefile
At the top of the makefile, there are several user-configurable parameters designed to enable the Makefile to be easily portable.

Variable | Description
---------|-------------
PROJECT  | Project name, used to name the binary
TARGET   | Target board/device to use
DEBUG    | 1 => compile with debugging symbols; 0 => compile with -Os

There are also a variety of rules that help with project management and debugging...

Rule    | Description
--------|-------------
clean   | Deletes automatically generated files (object files, logs, ...) and reverts submodules to their last commit
update  | Pulls lastest changes in submodules
size    | Outputs the size of the most recently compiled code
flash   | Writes current binary to micrcontroller flash
gdb     | Invokes gdb with the appropriate arguments
