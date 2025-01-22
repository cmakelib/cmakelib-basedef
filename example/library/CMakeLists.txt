##
#
# create shared library and package with header files
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
SET(CMAKE_PROJECT_NAME testlib)
PROJECT(${CMAKE_PROJECT_NAME})

#
# Use CMDEF library with defaults preset
#
FIND_PACKAGE(CMLIB COMPONENTS CMDEF)


#
# Set global compile options only for C++ language
#
IF(CMDEF_OS_LINUX)
	CMDEF_COMPILE_OPTIONS(
		LANG CXX
		DEBUG -O0
		RELEASE -O3
	)
ENDIF()

#
# Set global compile definitions
#
CMDEF_COMPILE_DEFINITIONS(
	DEBUG DEBUG
	RELEASE RELEASE
)

#
# Add shared library as standard CMake target
#
CMDEF_ADD_LIBRARY(
	LIBRARY_GROUP testlib
	TYPE SHARED
	SOURCES sources/test.cpp sources/test.c include/test.hpp  # Compile time sources
	INSTALL_INCLUDE_DIRECTORIES "include/"                    # Includes which will be part of package
	VERSION 1.2.1
)

#
# Specify -Wall for target 'testlib'
# and make the compile option public
#
CMDEF_COMPILE_OPTIONS_TARGET(
	TARGET testlib-shared
	VISIBILITY PUBLIC
	DEBUG -Wall
)

#
# Install testlib for given set of configurations.
#
CMDEF_INSTALL(
	TARGET testlib-shared
	NAMESPACE testlib-shared::
	CONFIGURATIONS Debug
)

#
# Create package for all available configurations.
# Only the installed one is defined correctly. (so the package for Release has
# undefined behaviour)
#
CMDEF_PACKAGE(
	MAIN_TARGET testlib-shared
	VERSION "1.2.5"
)

SET(CPACK_GENERATOR ZIP)
INCLUDE(CPack)
