## Main
#
# Initialize and set BUILD_TYPE.
#
# [Workflow]
# - Set enabled build types (see at CMDEF_BUILD_TYPE_LIST)
# - Check if the CMAKE_BUILD_TYPE is not empty
#		- If not empty check lie in enabled build types.
#		- if empty the var CMAKE_BUILD_TYPE is set to ${CMDEF_BUILD_TYPE_DEFAULT}
# - Set CMAKE_CONFIGURATION_TYPES to enabled (CMDEF_BUILD_TYPE_LIST)
#

INCLUDE_GUARD(GLOBAL)

##
# Used as configuration list for CMAKE_BUILD_TYPE_VARIABLE
#
SET(CMDEF_BUILD_TYPE_LIST Debug Release
	CACHE STRING
	"Allowed CMake configoration types"
)

SET(CMDEF_BUILD_TYPE_DEFAULT "Debug"
	CACHE STRING
	"Default build type if no CMAKE_BUILD_TYPE is specified"
)

MACRO(_CMDEF_BUILD_TYPE_SET_CMAKE_BUILD_TYPE_OVERRIDE opt ${ARGN})
	SET(CMDEF_BUILD_TYPE_CMAKE_BUILD_TYPE_OVERRIDE ${opt}
		CACHE BOOL
		"ON if the CMAKE_BUILD_TYPE is overridden by CMDEF, OFF otherwise"
		${ARGN}
	)
ENDMACRO()
_CMDEF_BUILD_TYPE_SET_CMAKE_BUILD_TYPE_OVERRIDE(OFF)

#
# Set uppercase variant of Build Types.
# Order must be preserved!
#
IF(NOT DEFINED CMDEF_BUILD_TYPE_LIST_UPPERCASE)
	SET(_uppercase)
	FOREACH(type ${CMDEF_BUILD_TYPE_LIST})
		STRING(TOUPPER ${type} upper_type)
		LIST(APPEND _uppercase ${upper_type})
	ENDFOREACH()
	SET(CMDEF_BUILD_TYPE_LIST_UPPERCASE
		${_uppercase}
		CACHE STRING
		"Uppercase list of Build types. The order of types must be the same as in CMDEF_BUILD_TYPE_LIST"
	)
	UNSET(_uppercase)
ENDIF()

#
# ALL is reserved keyword which represents all
# build types.
#
LIST(FIND CMDEF_BUILD_TYPE_LIST_UPPERCASE "ALL" all_find)
IF(NOT all_find EQUAL -1)
	MESSAGE(FATAL_ERROR "Build type cannot be ALL. All is reserved keyword which represents all build types")
ENDIF()
UNSET(all_find)



##
# Initialize CMake variables according to CMDEF definitions
#
# <function>(
# )
#
FUNCTION(CMDEF_BUILD_TYPE_INIT)
	SET(supported_build_types)
	IF(DEFINED CMAKE_BUILD_TYPE)
		IF(CMAKE_BUILD_TYPE STREQUAL "")
			SET(CMAKE_BUILD_TYPE "${CMDEF_BUILD_TYPE_DEFAULT}"
				CACHE STRING
				"Build type - initialized from CMDEF_BUILD_TYPE_DEFAULT"
				FORCE
			)
		_CMDEF_BUILD_TYPE_SET_CMAKE_BUILD_TYPE_OVERRIDE(ON FORCE)
		ENDIF()
		IF(NOT (CMAKE_BUILD_TYPE IN_LIST CMDEF_BUILD_TYPE_LIST))
			MESSAGE(FATAL_ERROR "Unsupported build type provided by CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
		ENDIF()
		SET(supported_build_types ${CMAKE_BUILD_TYPE})
	ELSE()
		SET(supported_build_types ${CMDEF_BUILD_TYPE_LIST})
	ENDIF()
	SET(CMAKE_CONFIGURATION_TYPES ${supported_build_types}
		CACHE STRING
		"CMake build types which can be available in multi-configuration generators"
		FORCE
	)
	MESSAGE(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
ENDFUNCTION()



##
# Check if the BUILD_TYPE is valid. If not error occurred.
#
# <function>(
#		<build_type>
# )
#
FUNCTION(CMDEF_BUILD_TYPE_CHECK build_type)
	LIST(FIND CMDEF_BUILD_TYPE_LIST "${build_type}" result)
	IF(result EQUAL -1)
		MESSAGE(FATAL_ERROR "Unsupported build type '${build_type}'")
	ENDIF()
ENDFUNCTION()



CMDEF_BUILD_TYPE_INIT()
