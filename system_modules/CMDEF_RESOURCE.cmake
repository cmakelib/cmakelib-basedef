## Main
#
# Manage resources for binaries. Specially for Windows.
#

INCLUDE_GUARD(GLOBAL)

FIND_PACKAGE(CMLIB REQUIRED)




##
#
# RESOURCE_TARGET is target to which the resource will be linked
#
# RESOURCE_FILE is absolute path to Resource file
#
# DEFINITIONS is list of key-value pairs which is treated as
# definitions for cmd line command which process RESOURCE_FILE
#
# <function> (
#		RESOURCE_TARGET <resource_target>
#		RESOURCE_FILE   <resource_file>
#		DEFINITINONS    <definitions> M
# )
#
FUNCTION(CMDEF_RESOURCE_WINDOWS)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			RESOURCE_TARGET
			RESOURCE_FILE
		MULTI_VALUE
			DEFINITIONS
		REQUIRED
			RESOURCE_TARGET
			RESOURCE_FILE DEFINITIONS
		P_ARGN ${ARGN}
	)

	IF(NOT (TARGET ${__RESOURCE_TARGET}))
		MESSAGE(FATAL_ERROR "'${__RESOURCE_TARGET}' is not valid CMake target!")
	ENDIF()
	IF((NOT EXISTS "${__RESOURCE_FILE}") OR (IS_DIRECTORY "${__RESOURCE_FILE}"))
		MESSAGE(FATAL_ERROR "Resource file '${__RESOURCE_FILE}' does not exist!")
	ENDIF()

	LIST(LENGTH __DEFINITIONS definitions_length)
	MATH(EXPR remainder "${definitions_length} % 2")
	IF(remainder)
		MESSAGE(FATAL_ERROR "DEFINITIONS has odd number of items!")
	ENDIF()

	GET_FILENAME_COMPONENT(resource_filename "${__RESOURCE_FILE}" NAME)
	SET(target_resource_filename "${__RESOURCE_TARGET}_${resource_filename}")
	SET(target_resource_dir "${CMAKE_CURRENT_BINARY_DIR}/resources")

	SET(file_definitions)
	FOREACH(def IN LISTS __DEFINITIONS)
		SET("local_${def}" )
	ENDFOREACH()

	SET(real_target ${__RESOURCE_TARGET})
	CMDEF_ADD_LIBRARY_CHECK(${__RESOURCE_TARGET} is_cmdef)
	IF(is_cmdef)
		SET(real_target ${is_cmdef})
	ENDIF()

	GET_TARGET_PROPERTY(type ${__RESOURCE_TARGET} TYPE)
	IF(type STREQUAL "SHARED_LIBRARY")
		LIST(APPEND file_definitions DLL)
	ELSEIF(type STREQUAL "STATIC_LIBRARY")
		LIST(APPEND file_definitions STATIC)
	ELSEIF(type STREQUAL "EXECUTABLE")
		LIST(APPEND file_definitions EXE)
	ENDIF()

	GET_SOURCE_FILE_PROPERTY(file_definitions "${target_resource_dir}/${target_resource_filename}" COMPILE_DEFINITIONS)
	IF(NOT file_definitions)
		SET(file_definitions)
	ENDIF()

	MATH(EXPR last_index "${definitions_length} - 1")
	FOREACH(i RANGE 0 ${last_index} 2)
		MATH(EXPR value_index "${i} + 1")
		LIST(GET __DEFINITIONS ${i} key)
		LIST(GET __DEFINITIONS ${value_index} value)
		STRING(REGEX MATCH "^[0-9]+\.?[0-9]*$" is_number "${value}")
		IF(is_number OR is_number STREQUAL "0")
			LIST(APPEND file_definitions "${key}=${value}")
		ELSE()
			LIST(APPEND file_definitions "${key}=\"${value}\"")
		ENDIF()
	ENDFOREACH()

	FILE(MAKE_DIRECTORY "${target_resource_dir}")
	CONFIGURE_FILE("${__RESOURCE_FILE}" "${target_resource_dir}/${target_resource_filename}" @ONLY)

	SET_PROPERTY(SOURCE "${target_resource_dir}/${target_resource_filename}"
		PROPERTY COMPILE_DEFINITIONS ${file_definitions}
	)

	TARGET_SOURCES(${real_target} PRIVATE 
		"${target_resource_dir}/${target_resource_filename}"
	)
	
ENDFUNCTION()
