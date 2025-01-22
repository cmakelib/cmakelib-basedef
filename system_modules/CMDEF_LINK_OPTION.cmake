## Main
#
# Link options - set link options (global or for target)
#

INCLUDE_GUARD(GLOBAL)

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/CMDEF_BUILD_TYPE.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/CMDEF_ADD_LIBRARY.cmake)



##
#
# BUILD_TYPE_UPPERCASE is uppercase version of build_type
# from BUILD_TYPE list.
#
# ALL is list of link options which will be add
# to each BUILD_TYPE
#
# LANG - array, if specified must be one of CMDEF_SUPPORTED_LANG_LIST.
# If not specified no exact language is select
#
# Each definition is passed to ADD_LINK_OPTIONS
# by generator_expression $<<CONFIG:build_type>:${option}>
#
# <function>(
#		[LANG <lang> M]
#		[ALL <compile_options>]
#		[<BUILD_TYPE_UPERCASE> <link_options>]{1,}
# )
#
FUNCTION(CMDEF_LINK_OPTIONS)
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
		FOREACH(option IN LISTS ${build_type_var})
			# CONFIG generator expression is case insensitive against value
			IF(DEFINED __LANG)
				SET(condition $<AND:$<COMPILE_LANGUAGE:${__LANG}>,$<CONFIG:${build_type}>>)
				SET(link_options $<${condition}:${option}>)
				ADD_LINK_OPTIONS(${link_options})
			ELSE()
				ADD_LINK_OPTIONS($<$<CONFIG:${build_type}>:${option}>)
			ENDIF()
		ENDFOREACH()
	ENDFOREACH()
ENDFUNCTION()



##
# Add link options to given target.
#
# BUILD_TYPE_UPPERCASE is uppercase version of build_type
# from BUILD_TYPE list.
#
# ALL is list of link options which will be add
# to each BUILD_TYPE
#
# LANG - array, if specified must be one of CMDEF_SUPPORTED_LANG_LIST.
# If not specified no exact language is select
#
# Each definition is passed to ADD_LINK_OPTIONS
# by generator_expression $<<CONFIG:build_type>:${option}>
#
# VISIBILITY is passed to visibility section of TARGET_LINK_OPTIONS.
# If no visibility specified than visibility is omitted
#
# <function>(
#		TARGET <target>
#		[LANG <lang> M]
#		[ALL <compile_options>]
#		[<BUILD_TYPE_UPPERCASE> <link_options>]{1,}
#		[VISIBILITY <INTERFACE|PUBLIC|PRIVATE>]
# )
#
FUNCTION(CMDEF_LINK_OPTIONS_TARGET)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			LANG ALL
			${CMDEF_BUILD_TYPE_LIST_UPPERCASE}
		ONE_VALUE
			TARGET
			VISIBILITY
		REQUIRED
			TARGET 
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
			SET(option ${${build_type_var}})
			SET(condition $<AND:$<COMPILE_LANGUAGE:${__LANG}>,$<CONFIG:${build_type}>>)
			SET(link_options $<${condition}:${option}>)
			TARGET_LINK_OPTIONS(${original_target_name} ${__VISIBILITY} ${link_options})
		ELSE()
			TARGET_LINK_OPTIONS(${original_target_name} ${__VISIBILITY} $<$<CONFIG:${build_type}>:${${build_type_var}}>)
		ENDIF()
	ENDFOREACH()
ENDFUNCTION()
