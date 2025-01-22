## Main
#
# Compile definition - set compile definitions (global or for target)
#

INCLUDE_GUARD(GLOBAL)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/CMDEF_BUILD_TYPE.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/CMDEF_ADD_LIBRARY.cmake)



##
# Add global compile definitions for given build type.
#
# ALL is list of definitions which will be add
# to each BUILD_TYPE
#
# BUILD_TYPE_UPPERCASE is uppercase version of build_type
# from BUILD_TYPE list.
#
# LANG -array, if specified must be one of CMDEF_SUPPORTED_LANG_LIST.
# If not specified no exact language is select
#
# Each definition is passed to ADD_COMPILE_DEFINITION
# by generator_expression $<<CONFIG:build_type>:${definitnion}>
#
# <function>(
#		[LANG <lang>]
#		[ALL <compile_definitions>]
#		[<BUILD_TYPE_UPERCASE> <compile_definitions>]{1,}
# )
#
FUNCTION(CMDEF_COMPILE_DEFINITIONS)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			LANG ALL
			${CMDEF_BUILD_TYPE_LIST_UPPERCASE}
		P_ARGN ${ARGN}
	)

	IF(DEFINED __LANG)
		CMUTIL_TRAIT_IN_ARRAY(VALUES ${__LANG} ARRAY CMDEF_SUPPORTED_LANG_LIST
			DESCRIPTION "Unsupported language")
	ENDIF()

	FOREACH(build_type IN LISTS CMDEF_BUILD_TYPE_LIST_UPPERCASE)
		SET(build_type_var __${build_type})
		IF(DEFINED __ALL)
			LIST(APPEND ${build_type_var} ${__ALL})
		ENDIF()
		IF(NOT DEFINED ${build_type_var})
			CONTINUE()
		ENDIF()
		FOREACH(definition IN LISTS ${build_type_var})
			IF(DEFINED __LANG)
				SET(condition $<AND:$<COMPILE_LANGUAGE:${__LANG}>,$<CONFIG:${build_type}>>)
				SET(compile_definitions $<${condition}:${definition}>)
				ADD_COMPILE_DEFINITIONS(${compile_definitions})
			ELSE()
				ADD_COMPILE_DEFINITIONS($<$<CONFIG:${build_type}>:${definition}>)
			ENDIF()
		ENDFOREACH()
	ENDFOREACH()
ENDFUNCTION()



##
# Set compile options for given target
#
# ALL is list of definitions which will be add
# to each BUILD_TYPE
#
# BUILD_TYPE_UPPERCASE is uppercase version of build_type
# from BUILD_TYPE list.
#
# LANG - array, if specified must be one of CMDEF_SUPPORTED_LANG_LIST.
# If not specified no exact language is select
#
# Each definition is passed to TARGET_COMPILE_DEFINITION
# by generator_expression $<<CONFIG:build_type>:${definitnion}>
#
# VISIBILITY is passed to visibility section of TARGET_LINK_OPTIONS.
# If no visibility specified than visibility is omitted
#
# <function>(
#		TARGET <target>
#		[LANG <lang> M]
#		[ALL <compile_definitions>]
#		[<BUILD_TYPE_UPPERCASE> <link_options>]{1,}
#		[VISIBILITY <INTERFACE|PUBLIC|PRIVATE>]
# )
#
FUNCTION(CMDEF_COMPILE_DEFINITIONS_TARGET)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			LANG ALL
			${CMDEF_BUILD_TYPE_LIST_UPPERCASE}
		ONE_VALUE
			TARGET
			VISIBILITY
		REQUIRED
			TARGET VISIBILITY
		P_ARGN ${ARGN}
	)

	IF(DEFINED __LANG)
		CMUTIL_TRAIT_IN_ARRAY(VALUES ${__LANG} ARRAY CMDEF_SUPPORTED_LANG_LIST
			DESCRIPTION "Unsupported language")
	ENDIF()

	SET(original_target_name ${__TARGET})

	FOREACH(build_type IN LISTS CMDEF_BUILD_TYPE_LIST_UPPERCASE)
		SET(build_type_var __${build_type})
		IF(DEFINED __ALL)
			LIST(APPEND ${build_type_var} ${__ALL})
		ENDIF()
		IF(NOT DEFINED ${build_type_var})
			CONTINUE()
		ENDIF()	
		IF(DEFINED __LANG)
			SET(condition $<AND:$<COMPILE_LANGUAGE:${__LANG}>,$<CONFIG:${build_type}>>)
			SET(compile_definitions $<${condition}:${${build_type_var}}>)
			TARGET_COMPILE_DEFINITIONS(${original_target_name} ${__VISIBILITY} ${compile_definitions})
		ELSE()
			TARGET_COMPILE_DEFINITIONS(${original_target_name} ${__VISIBILITY} $<$<CONFIG:${build_type}>:${${build_type_var}}>)
		ENDIF()
	ENDFOREACH()
ENDFUNCTION()
