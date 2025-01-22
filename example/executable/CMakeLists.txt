#
# Example project
#
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
SET(CMAKE_PROJECT_NAME executable)
PROJECT(${CMAKE_PROJECT_NAME})

#
# Use CMDEF library in same manner as COMPONENT mechanism
# in CMLIB
#
FIND_PACKAGE(CMLIB COMPONENTS CMDEF)


CMDEF_CLEANUP()

#
# Add Definitions for each build type globally
# so each target will have these definitions
#
CMDEF_COMPILE_DEFINITIONS(
	DEBUG DEBUG_FLAG_OK
	RELEASE RELEASE_FLAG_OK
	ALL ALL_FLAG_OK
)

#
# Specify global compile options.
# Variants for LINK and DEFINES options are available too.
#
IF(CMDEF_OS_LINUX)
	CMDEF_COMPILE_OPTIONS(
		ALL -Wall       # Specify compile flags for All build types
		DEBUG -gdwarf-4 # Specify compile flag only for Debug
	)
ELSEIF(CMDEF_OS_WINDOWS)
	CMDEF_COMPILE_OPTIONS(
		ALL /wd4996 # Disable deprecation warning on Windows OS
	)
ENDIF()

#
# Add CMake executable.
# Function will create standard CMake executable target so
# standard CMake functions can be used
#
CMDEF_ADD_EXECUTABLE(
	TARGET executable
	SOURCES main.c
	VERSION 2.98.0
)

CMDEF_COMPILE_DEFINITIONS_TARGET(
	TARGET executable
	VISIBILITY PUBLIC
	ALL RETURN_CODE=245
	DEBUG RETURN_CODE_DEBUG=1000
	RELEASE RETURN_CODE_RELEASE=2020
)

#
# Create standard CMake executable
# and add definitions by CMDEF macro
#
ADD_EXECUTABLE(cmake_executable main.c)
CMDEF_COMPILE_DEFINITIONS_TARGET(
	TARGET cmake_executable
	VISIBILITY PRIVATE
	ALL RETURN_CODE=255
	DEBUG RETURN_CODE_DEBUG=10000
	RELEASE RETURN_CODE_RELEASE=20200
)

#
# Install execubtable to predefined directories so the
# package structure is stable...
#
CMDEF_INSTALL(TARGET executable NAMESPACE executable::)
CMDEF_INSTALL(TARGET cmake_executable)

#
# Create package - only sets some presets for CPack.
# Function does not include CPack!
# Function does not specify generators or any generator specific setting.
#
CMDEF_PACKAGE(
	MAIN_TARGET executable
	VERSION 1.0.98    # It's a package version
)

#
# Just choose generator and include CPack
#
SET(CPACK_GENERATOR ZIP)
INCLUDE(CPack)

function(dump_cmake_variables)
    get_cmake_property(_variableNames VARIABLES)
    list (SORT _variableNames)
    foreach (_variableName IN LISTS _variableNames)
            message(STATUS "${_variableName}=${${_variableName}}")
    endforeach()
endfunction()
dump_cmake_variables()