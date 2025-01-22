
# CMDEf cache variables

Each section represent one Cache variable used in CMDEF.

Each variable can be set from cmd line by -D option of the `cmake` utility if not explicitly forbidden.

Each variable has a type String unless otherwise stated.

Each section has the following format

```
## VAR_NAME:TYPE=DEFAULT_VALUE
1. short description
1. CMake cache type if different from String
1. fill up rules 
```

If the `DEFAULT_VALUE` = `<conditional>` then the value definition is a part of the description.


## CMDEF_ARCHITECTURE:STRING=\<conditional>

Processor architecture of the target system.

It tries to set the variable in the following order

1. filled from cmdline of the `cmake` utility by -D if specified
1. filled from ENV variable CMDEF_ARCHITECTURE if defined
1. auto filled by CMDEF library (by `uname`)

## CMDEF_BUILD_TYPE_CMAKE_BUILD_TYPE_OVERRIDE:BOOL=\<conditional>

Indicate if the CMAKE_BUILD_TYPE is overridden by CMDEF library.

- If the CMAKE_BUILD_TYPE is not set the CMDEF try to set the CMAKE_BUILD_TYPE variable
  to the predefined value stored in CMDEF_BUILD_TYPE_DEFAULT variable. In this case the variable is set to ON.
- If the CMAKE_BUILD_TYPE is set explicitly the variable is set to OFF.

## CMDEF_BUILD_TYPE_DEFAULT:STRING=Debug

Default build type if CMAKE_BUILD_TYPE is not specified.

## CMDEF_BUILD_TYPE_LIST:STRING,LIST=\<conditional>

List of the supported byuld types. CMAKE_BUILD_TYPE must hold exactly one value from this list.

Type: String, List

- Default value: list of ["Debug", "Release"]

## CMDEF_BUILD_TYPE_LIST_UPPERCASE:STRING,LIST=\<conditional>

Uppercase version of CMDEF_BUILD_TYPE_LIST.

Type: String, List

- each element of the list is an uppercase version of value from CMAKE_BUILT_TYPE_LIST
- each value from CMAKE_BUILT_TYPE_LIST is present only once.

## CMDEF_DISTRO_ID:STRING=\<conditional>

Distribution name (eg debian, ubuntu, ...). It always holds lowercase value...

It tries to set the variable in the following order

1. filled from ENV variable CMDEF_DISTRO_ID if defined
1. auto filled by CMDEF library (by `lsb_release` utility)

## CMDEF_DISTRO_VERSION_ID:STRING=\<conditional\>

Distribution version ID (eg for debian bullseye: 11, ...). It always holds lowercase value...

It tries to set the variable in the following order

1. filled from ENV variable CMDEF_DISTRO_VERSION_ID if defined
1. auto filled by CMDEF library (by `lsb_release` utility)

## CMDEF_ENV_DESCRIPTION_COMPANY_NAME:STRING=Company name

Name of the company name mainly used for package

## CMDEF_ENV_DESCRIPTION_COPYRIGHT:STRING=Company name

Copyright. Mainly used for the package and project description.

## CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX:STRING=d

Suffix for the output executable name for the Debug configuration.

## CMDEF_BINARY_INSTALL_DIR:PATH=bin

Name of the install directory for binary files

## CMDEF_INCLUDE_INSTALL_DIR:PATH=include

Name of the install directory for include files/directories

## CMDEF_LIBRARY_INSTALL_DIR:PATH=lib

Name of the install directory for library files (.so, .a, ...)

## CMDEF_LIBRARY_NAME_DEBUG_SUFFIX:STRING=d

Suffix for the output library name for the Debug configuration.

## CMDEF_LIBRARY_NAME_FLAG_SHARED:STRING=""

Suffix for the output dynamic library name.

## CMDEF_LIBRARY_NAME_FLAG_STATIC:STRING=-static

Suffix for the output library name.

## CMDEF_LIBRARY_NAME_SUFFIX_SHARED:STRING=\<conditional\>

File extension of the Shared library.

- Set by the host system from appropriate CMDEF_LIBRARY_NAME_SUFFIX_SHARED_* var.

## CMDEF_LIBRARY_NAME_SUFFIX_SHARED_LINUX:STRING=so

Linux shared library extension.

## CMDEF_LIBRARY_NAME_SUFFIX_SHARED_MACOS:STRING=.dylib

Mac OS shared library extension.

## CMDEF_LIBRARY_NAME_SUFFIX_SHARED_WINDOWS:STRING=.dll

Windows shared library extension.

## CMDEF_LIBRARY_NAME_SUFFIX_STATIC:STRING=.a

## CMDEF_LIBRARY_NAME_SUFFIX_STATIC_LINUX:STRING=.a

## CMDEF_LIBRARY_NAME_SUFFIX_STATIC_MACOS:STRING=.a

## CMDEF_LIBRARY_NAME_SUFFIX_STATIC_WINDOWS:STRING=.lib

## CMDEF_LIBRARY_PREFIX:STRING=lib

## CMDEF_LSB_RELEASE:FILEPATH=\<conditional>

## CMDEF_MULTICONF_FOLDER_NAME:BOOL=CMDEF

## CMDEF_OS_LINUX:BOOL=ON

## CMDEF_OS_MACOS:BOOL=OFF

## CMDEF_OS_NAME:STRING=linux

## CMDEF_OS_NAME_SHORT:STRING=lin

## CMDEF_OS_POSIX:BOOL=ON

## CMDEF_OS_WINDOWS:BOOL=OFF

## CMDEF_SUPPORTED_LANG_LIST:STRING=C;CXX;OBJC;OBJCXX;RC

## CMDEF_TARGET_OUTPUT_DIRECTORY:PATH=\<conditional>

Only for Multi-config.

Variable holds output path where the build for each build type will be stored.

## CMDEF_UNAME:FILEPATH=\<conditional>
