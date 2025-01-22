##
#
# Example creates shared library and package with header files
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
SET(CMAKE_PROJECT_NAME testlib)
PROJECT(${CMAKE_PROJECT_NAME})

SET(CMAKE_INSTALL_RPATH $ORIGIN/../lib/)
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
# Add interface library used to provide include dirs, sources and
# other compile time options from defined interface to testlib
#
CMDEF_ADD_LIBRARY(
	LIBRARY_GROUP interfacelib-second
	TYPE INTERFACE
	SOURCES sources/second/InterfaceSecond.cpp sources/second/InterfaceFirst.cpp
	INSTALL_INCLUDE_DIRECTORIES "include_second/"
	INCLUDE_DIRECTORIES         "${CMAKE_CURRENT_LIST_DIR}/include_second/"
	VERSION 1.2.1
)

#
# Add interface library packed with a shared library testlib
# Note:
#
CMDEF_ADD_LIBRARY(
	LIBRARY_GROUP interfacelib-third
	TYPE INTERFACE
	SOURCES 					sources/third/InterfaceThird.cpp
	SOURCE_BASE_DIRECTORY       sources/ # Needed only for library installation
	INSTALL_INCLUDE_DIRECTORIES "include_third/"
	INCLUDE_DIRECTORIES         "${CMAKE_CURRENT_LIST_DIR}/include_third/"
	VERSION 1.2.1
)

#
# Add shared library which is core of the project
#
CMDEF_ADD_LIBRARY(
	LIBRARY_GROUP testlib
	TYPE SHARED
	SOURCES sources/testlib/printAllMessages.cpp sources/test_c.cpp      # Interface sources used
	INSTALL_INCLUDE_DIRECTORIES "include/"       # Includes which will be part of package
	INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/include/"
	VERSION 1.5.0
)

#
# Inherit all needed interface related stuff for build of testlib.
# Make it PRIVATE so it will not be exported as part of the installation or package
#
TARGET_LINK_LIBRARIES(testlib-shared PRIVATE interfacelib-second-interface)

#
# Link interface which will be then installed together with
# a shared library. 
#
TARGET_LINK_LIBRARIES(testlib-shared INTERFACE interfacelib-third-interface)


#
# Test if all link libraries are correctly linked
# and all symbols are available
#
CMDEF_ADD_EXECUTABLE(
	TARGET testlink-executable
	SOURCES main.cpp
	VERSION 1.5.0
)
TARGET_LINK_LIBRARIES(testlink-executable PRIVATE testlib-shared)
CMDEF_INSTALL(TARGET testlink-executable NAMESPACE testlib-shared::)

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
	CONFIGURATIONS Debug
	NAMESPACE testlib-shared::
)

#
# Install testlib for given set of configurations.
#
CMDEF_INSTALL(
	TARGET interfacelib-third-interface
	CONFIGURATIONS Debug
	NAMESPACE testlib-shared::
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
