## Main
#
# initialize base CMDEF CMake variables.
#
# Module relay on some CMake variables like
# - CMAKE_CURRENT_BINARY_DIR (defined as "${CMAKE_CURRENT_LIST_DIR}" for script mode)
#

INCLUDE_GUARD(GLOBAL)

FIND_PACKAGE(CMLIB REQUIRED)

#
# Variable that is defined only as local.
# Is not intended to be modified by user
#
# It holds list of supported/well_tested architectures
#
# aplsil architecture referes to Apple silicon 
#
SET(_CMDEF_ENV_SUPPORTED_ARCH_LIST "x86-64" "x86" "aarch64" "aplsil")



##
# Initialize CMDEF CMake variables.
#
# <function>(
# )
#
FUNCTION(CMDEF_ENV_INIT)

	_CMDEF_ENV_SET_OS()
	_CMDEF_ENV_SET_PACKAGE(${CMDEF_OS_NAME})
	_CMDEF_ENV_SET_OUTPUT_DIR()
	_CMDEF_ENV_SET_TARGET_INSTALL_DIR()
	_CMDEF_ENV_SET_DESCRIPTION()
	_CMDEF_ENV_SET_NAMING_CONVENTION()
	_CMDEF_ENV_SET_SUPPORTED_LANG()

	IF(CMDEF_OS_WINDOWS)
		IF(NOT CMDEF_WINDOWS_EXECUTABLE_MT)
			FIND_PROGRAM(CMDEF_WINDOWS_EXECUTABLE_MT "mt.exe")
			IF(${CMDEF_WINDOWS_EXECUTABLE_MT} STREQUAL "${prefix}WINDOWS_EXECUTABLE_MT-NOTFOUND")
				MESSAGE(WARNING "Could not find mt.exe. Some functionality may not be available. Suggesting mt.exe")
				SET(CMDEF_WINDOWS_EXECUTABLE_MT "mt.exe" CACHE STRING "mt.exe" FORCE)
			ENDIF()
		ENDIF()
	ENDIF()
	IF(CMDEF_OS_MACOS)
		FIND_PROGRAM(CMDEF_MACOS_EXECUTABLE_IBTOOL ibtool
			HINTS "/usr/bin" "${OSX_DEVELOPER_ROOT}/usr/bin")
		IF(${CMDEF_MACOS_EXECUTABLE_IBTOOL} STREQUAL "${prefix}MACOS_EXECUTABLE_IBTOOL-NOTFOUND")
			MESSAGE(SEND_ERROR "Could not find 'ibtool'. Some functionality may not be available")
		ENDIF()
	ENDIF()

	SET(CMDEF_MULTICONF_FOLDER_NAME "CMDEF"
		CACHE PATH
		"Name of folder for CMDEF targets in multiconfig like Visual Studio"
	)

ENDFUNCTION()



## Helper
# Set package variables
#
# <function>(
# )
#
MACRO(_CMDEF_ENV_SET_PACKAGE os_name)
	SET(CMDEF_LIBRARY_PREFIX "lib"
		CACHE STRING
		"Suffix for package names if the installed target is library"
	)
	SET(CMDEF_LIBRARY_NAME_FLAG_STATIC "-static"
		CACHE STRING
		"Flag which is appended to library name and CMDEF_*_NAME_DEBUG_SUFFIX"
	)
	SET(CMDEF_LIBRARY_NAME_FLAG_SHARED ""
		CACHE STRING
		"Flag which is appended to library name and CMDEF_*_NAME_DEBUG_SUFFIX"
	)
	SET(CMDEF_LIBRARY_NAME_DEBUG_SUFFIX "d"
		CACHE STRING
		"Suffix for library name if the target is configured in debug"
	)
	SET(CMDEF_LIBRARY_NAME_DEV_SUFFIX "-dev"
		CACHE STRING
		"Suffix for development library"
	)
	SET(CMDEF_EXECUTABLE_NAME_DEBUG_SUFFIX "d"
		CACHE STRING
		"Suffix for executable name if the target is configured in debug"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_STATIC_WINDOWS ".lib"
		CACHE STRING
		".lib"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_SHARED_WINDOWS ".dll"
		CACHE STRING
		".dll"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_STATIC_LINUX ".a"
		CACHE STRING
		".a"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_SHARED_LINUX ".so"
		CACHE STRING
		".so"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_STATIC_MACOS ".a"
		CACHE STRING
		".a"
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_SHARED_MACOS ".dylib"
		CACHE STRING
		".dylib"
	)

	IF(NOT DEFINED CMDEF_OS_NAME_UPPER)
		MESSAGE(FATAL_ERROR "")
	ENDIF()

	SET(shared_var_name CMDEF_LIBRARY_NAME_SUFFIX_SHARED_${CMDEF_OS_NAME_UPPER})
	SET(static_var_name CMDEF_LIBRARY_NAME_SUFFIX_STATIC_${CMDEF_OS_NAME_UPPER})
	IF(NOT DEFINED ${shared_var_name} OR
			NOT DEFINED ${static_var_name})
		MESSAGE(FATAL_ERROR "Undefined suffix variable!")
	ENDIF()
	SET(CMDEF_LIBRARY_NAME_SUFFIX_SHARED "${${shared_var_name}}"
		CACHE STRING
		"Suffix for shared library. Determined by host OS."
	)
	SET(CMDEF_LIBRARY_NAME_SUFFIX_STATIC "${${static_var_name}}"
		CACHE STRING
		"Suffix for static library. Determined by host OS."
	)
ENDMACRO()



## Helper
# Set naming convention variables
#
# <function>(
# )
#
FUNCTION(_CMDEF_ENV_SET_NAMING_CONVENTION)
	SET(CMDEF_ENV_NAME_SEPARATOR "_"
			CACHE STRING
			"Separator for package name"
	)
	SET(CMDEF_ENV_NAMESPACE_SUFFIX "::"
			CACHE STRING
			"Suffix for namespace"
	)
ENDFUNCTION()



## Helper
# Set and control list of supported languages
# 
# <function> (
# )
#
FUNCTION(_CMDEF_ENV_SET_SUPPORTED_LANG)
	SET(CMDEF_SUPPORTED_LANG_LIST C;CXX;OBJC;OBJCXX;RC;
		CACHE STRING
		"Supported programming languages"
	)
	SET(CMDEF_LANG_CXX_SOURCE_FILE_EXTENSIONS .cpp .cc .cxx .hpp
		CACHE STRING
		"List of C++ source file extensions"
	)
	SET(CMDEF_LANG_C_SOURCE_FILE_EXTENSIONS .c .h
		CACHE STRING
		"List of C source file extensions"
	)
	SET(CMDEF_LANG_OBJC_SOURCE_FILE_EXTENSIONS .m .h
		CACHE STRING
		"List of OBJC source file extensions"
	)
	SET(CMDEF_LANG_OBJCXX_SOURCE_FILE_EXTENSIONS .mm
		CACHE STRING
		"List of OBJCXX source file extensions"
	)
	SET(CMDEF_LANG_RC_SOURCE_FILE_EXTENSIONS .rc
		CACHE STRING
		"List of RC source file extensions"
	)
ENDFUNCTION()



## Helper
# Define variables for OS
#
# <function> (
# )
#
MACRO(_CMDEF_ENV_SET_OS)
	CMAKE_HOST_SYSTEM_INFORMATION(RESULT _os_name QUERY OS_NAME)
	MESSAGE(STATUS "System name: ${_os_name}")
	SET(os_name "")
	IF("${_os_name}" STREQUAL "Darwin" OR
			"${_os_name}" STREQUAL "Mac OS X" OR
			"${_os_name}" STREQUAL "macOS")
		SET(os_name "macos")
	ELSEIF("${_os_name}" STREQUAL "Linux")
		SET(os_name "linux")
	ELSEIF("${_os_name}" STREQUAL "Windows")
		SET(os_name "windows")
	ENDIF()

	SET(CMDEF_OS_NAME ${os_name}
		CACHE STRING
		"String, normalized representation of OS name"
	)
	IF("${CMDEF_OS_NAME}" STREQUAL "macos")
		SET(_OS_MACOS  ON)
		SET(_OS_POSIX   ON)
		SET(_OS_WINDOWS OFF)
		SET(_OS_LINUX   OFF)
		SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
	ELSEIF("${CMDEF_OS_NAME}" STREQUAL "linux")
		SET(_OS_LINUX ON)
		SET(_OS_POSIX ON)
		SET(_OS_WINDOWS OFF)
		SET(_OS_MACOS  OFF)
	ELSEIF("${CMDEF_OS_NAME}" STREQUAL "windows")
		SET(_OS_LINUX OFF)
		SET(_OS_POSIX OFF)
		SET(_OS_WINDOWS ON)
		SET(_OS_MACOS  OFF)
		SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
	ELSE()
		MESSAGE(FATAL_ERROR "Unsupported CMDEF_OS_NAME value: ${CMDEF_OS_NAME}")
	ENDIF()

	STRING(SUBSTRING "${CMDEF_OS_NAME}" 0 3 os_name_short)
	SET(CMDEF_OS_NAME_SHORT ${os_name_short}
		CACHE STRING
		"Short-string representation of OS name"
	)
	
	STRING(TOUPPER ${CMDEF_OS_NAME} os_name_upper)
	SET(CMDEF_OS_NAME_UPPER ${os_name_upper}
		CACHE INTERNAL
		"String representation of OS name - upper case"
		FORCE
	)

	SET(CMDEF_OS_MACOS ${_OS_MACOS}
		CACHE BOOL
		"OS version/type"
	)
	SET(CMDEF_OS_WINDOWS ${_OS_WINDOWS}
		CACHE BOOL
		"OS version/type"
	)
	SET(CMDEF_OS_LINUX ${_OS_LINUX}
		CACHE BOOL
		"OS version/type"
	)
	SET(CMDEF_OS_POSIX ${_OS_POSIX}
		CACHE BOOL
		"Do we have POSIX OS?"
	)

	IF(NOT CMDEF_ARCHITECTURE)
		SET(arch)
		IF(NOT "$ENV{CMDEF_ARCHITECTURE}" STREQUAL "")
			SET(arch "$ENV{CMDEF_ARCHITECTURE}")
		ELSE()
			_CMDEF_ENV_GET_ARCH(arch)
		ENDIF()
		SET(CMDEF_ARCHITECTURE ${arch}
			CACHE STRING
			"Architecture for which we will compile"
		)
	ENDIF()
	MESSAGE(STATUS "Architecture: ${CMDEF_ARCHITECTURE}")
	LIST(FIND _CMDEF_ENV_SUPPORTED_ARCH_LIST "${CMDEF_ARCHITECTURE}" arch_found)
	IF(arch_found EQUAL -1)
		MESSAGE(WARNING "Unsupported Architecture: ${CMDEF_ARCHITECTURE}")
	ENDIF()

	IF (NOT CMDEF_DISTRO_ID)
		SET(distro_id)
		IF(NOT "$ENV{CMDEF_DISTRO_ID}" STREQUAL "")
			SET(distro_id "$ENV{CMDEF_DISTRO_ID}")
		ELSE()
			_CMDEF_ENV_GET_DISTRO_ID(distro_id)
		ENDIF()
		SET(CMDEF_DISTRO_ID ${distro_id}
			CACHE STRING
			"Distro ID for which we will compile"
		)
	ENDIF()
	MESSAGE(STATUS "Distro ID: ${CMDEF_DISTRO_ID}")

	IF (NOT CMDEF_DISTRO_VERSION_ID)
		SET(version_id)
		IF(NOT "$ENV{CMDEF_DISTRO_VERSION_ID}" STREQUAL "")
			SET(version_id "$ENV{CMDEF_DISTRO_VERSION_ID}")
		ELSE()
			_CMDEF_ENV_GET_DISTRO_VERSION_ID(version_id)
		ENDIF()
		SET(CMDEF_DISTRO_VERSION_ID ${version_id}
			CACHE STRING
			"Distro Version ID for which we will compile"
		)
	ENDIF()
	MESSAGE(STATUS "Distro Version ID: ${CMDEF_DISTRO_VERSION_ID}")
ENDMACRO()



## Helper
# Set output directory variable
#
# <function>(
#		<prefix>
# )
#
MACRO(_CMDEF_ENV_SET_OUTPUT_DIR)
	SET(CMDEF_TARGET_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>"
		CACHE PATH
		"Output directory for CMake targets"
	)
ENDMACRO()



## Helper
# Set install dir names which serve as DESTINATION
# for 'install' command.
#
# All install dirs must be one level. Two level dirs are note supported!
#
# <function>(
#		<prefix>
# )
#
MACRO(_CMDEF_ENV_SET_TARGET_INSTALL_DIR)
	SET(CMDEF_INCLUDE_INSTALL_DIR "include/"
		CACHE PATH
		"Name of include directory after install (in package)"
	)
	SET(CMDEF_SOURCE_INSTALL_DIR "source/"
		CACHE PATH
		"Name of source directory after install (in package)"
	)
	SET(CMDEF_LIBRARY_INSTALL_DIR "lib/"
		CACHE PATH
		"Name of library directory after install (in package)"
	)
	SET(CMDEF_BINARY_INSTALL_DIR "bin/"
		CACHE PATH
		"Name of bin directory after install (in package)"
	)
ENDMACRO()



## Helper
#
# 
#
# <function>(
# )
#
FUNCTION(_CMDEF_ENV_SET_WINDOWS_FLAGS)
	IF(NOT DEFINED CMDEF_OS_WINDOWS)
		MESSAGE(FATAL_ERROR "Cannot determine target OS. Not defined.")
	ENDIF()
	IF(NOT CMDEF_OS_WINDOWS)
		RETURN()
	ENDIF()

	SET(CMDEF_WINDOWS_STATIC_RUNTIME ON
		CACHE BOOL
		"If ON then STATIC runtime is used, of OFF DYNAMIC runtime is used"
	)
ENDFUNCTION()



## Helper
#
# <function> (
#		
#)
#
FUNCTION(_CMDEF_ENV_SET_DESCRIPTION)
	SET(CMDEF_ENV_DESCRIPTION_COMPANY_NAME "Company name"
		CACHE STRING
		"Name of the company"
	)
	SET(CMDEF_ENV_DESCRIPTION_COPYRIGHT "${CMDEF_ENV_DESCRIPTION_COMPANY_NAME}"
		CACHE STRING
		"Copyright which will be added to binaries"
	)
ENDFUNCTION()



## Helper
#
# Determine architecture.
# If the cannot be determined is set to 'unknown'
#
# <function>(
#		<arch_output_var_name>
# )
#
FUNCTION(_CMDEF_ENV_GET_ARCH arch)
	IF(CMDEF_OS_WINDOWS)
		SET(${arch} "x86-64" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(CMDEF_OS_MACOS)
		SET(${arch} "aplsil" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(CMDEF_OS_LINUX)
		CMAKE_HOST_SYSTEM_INFORMATION(RESULT _arch QUERY OS_PLATFORM)
		STRING(REGEX REPLACE "[^a-zA-Z0-9.]" "-" _arch_mapped "${_arch}")
		STRING(TOLOWER "${_arch_mapped}" _arch_normalized)
		IF(NOT _arch_normalized)
			MESSAGE(FATAL_ERROR "Cannot determine system architecture."
				" It seems the system has system arch set to empty or invalid string."
				" Consult os-release file."
			)
		ENDIF()
		SET(${arch} "${_arch_normalized}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	MESSAGE(FATAL_ERROR "Cannot get architecture for unknown OS ${CMDEF_OS_NAME}")
ENDFUNCTION()



## Helper
#
# Determine distribution ID
#
# <function>(
#		<distro_id_var_name>
# )
#
FUNCTION(_CMDEF_ENV_GET_DISTRO_ID distro_id)
	IF(CMDEF_OS_WINDOWS)
		SET(${distro_id} "${CMDEF_OS_NAME}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(CMDEF_OS_MACOS)
		SET(${distro_id} "${CMDEF_OS_NAME}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(CMDEF_OS_LINUX)
		CMAKE_HOST_SYSTEM_INFORMATION(RESULT _distro_id QUERY DISTRIB_ID)
		STRING(REGEX REPLACE "[^a-zA-Z0-9.]" "-" _distro_id_mapped "${_distro_id}")
		STRING(TOLOWER "${_distro_id_mapped}" _distro_id_normalized)
		IF(NOT _distro_id_normalized)
			MESSAGE(FATAL_ERROR "Cannot determine Distro ID."
				" It seems the system has Distro ID set to empty or invalid string."
				" Consult os-release file."
			)
		ENDIF()
		SET(${distro_id} "${_distro_id_normalized}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	MESSAGE(FATAL_ERROR "Cannot get distro id for unknown OS ${CMDEF_OS_NAME}")
ENDFUNCTION()



## Helper
#
# Determine Distro Version ID
#
# <function>(
#		<version_id_var_name>
# )
#
FUNCTION(_CMDEF_ENV_GET_DISTRO_VERSION_ID version_id)
	IF(CMDEF_OS_WINDOWS)
		SET(${version_id} "1" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(CMDEF_OS_MACOS)
		SET(${version_id} "11" PARENT_SCOPE)
		RETURN()
	ENDIF()
	IF(CMDEF_OS_LINUX)
		CMAKE_HOST_SYSTEM_INFORMATION(RESULT _version_id QUERY DISTRIB_VERSION_ID)
		STRING(REGEX REPLACE "[^a-zA-Z0-9.]" "-" _version_id_mapped "${_version_id}")
		STRING(TOLOWER "${_version_id_mapped}" _version_id_normalized)
		IF(NOT _version_id_normalized)
			MESSAGE(FATAL_ERROR "Cannot determine Distro Version ID."
				" It seems the system has Distro Version ID set to empty or invalid string."
				" Consult os-release file."
			)
		ENDIF()
		SET(${version_id} "${_version_id_normalized}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	MESSAGE(FATAL_ERROR "Cannot get distro id for unknown OS ${CMDEF_OS_NAME}")
ENDFUNCTION()

CMDEF_ENV_INIT()
