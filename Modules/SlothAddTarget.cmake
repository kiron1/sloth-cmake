#
# SlothAddTarget.cmake - Defines high level functions to add targets.
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

if(_SLOTH_ADD_TARGET_CMAKE_INCLUDED)
  return()
endif()
set(_SLOTH_ADD_TARGET_CMAKE_INCLUDED 1)

if(POLICY CMP022)
  cmake_policy(PUSH)
  cmake_policy(SET CMP0022 NEW)
endif()

include(CMakeParseArguments)

function(sloth_parse_target_arguments _in)
  set(_flags
    EXCLUDE_FROM_ALL
    EXCLUDE_FROM_DEFAULT_BUILD
    EXCLUSE_FROM_INSTALL
    STATIC
    SHARED
    MODULE
    INTERFACE
    IMPORTED
    GLOBAL
    WIN32
    MACOSX_BUNDLE
  )

  set(_opts
    GROUP
    ALIAS
    IMPORTED_LOCATION
    COMMAND
    WORKING_DIRECTORY
  )

  set(_args
    SOURCES
    ADDITIONAL_SOURCES
    COMPILE_OPTIONS
    COMPILE_DEFINITIONS
    INCLUDE_DIRECTORIES
    LINK_LIBRARIES
    DEPENDS
    CONFIGURATIONS
  )

  set(_keys ${_flags} ${_opts} ${_args})

  cmake_parse_arguments("_a" "" "${_keys}" "" ${ARGN})

  cmake_parse_arguments("_arg"
    "${_flags}"
    "${_opts}"
    "${_args}"
    ${_in}
  )

  foreach(_k IN LISTS _keys ITEMS UNPARSED_ARGUMENTS)
    if("_a_${_k}")
      set("${_a_${_k}}" ${_arg_${_k}} PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(sloth_target_setup _name)
  sloth_parse_target_arguments("${ARGN}"
    EXCLUDE_FROM_ALL           _exclude_from_all
    EXCLUDE_FROM_DEFAULT_BUILD _exclude_from_default_build
    GROUP                      _group
    COMPILE_OPTIONS            _cflags
    COMPILE_DEFINITIONS        _defines
    INCLUDE_DIRECTORIES        _includes
    LINK_LIBRARIES             _link_libs
    DEPENDS                    _depends
    UNPARSED_ARGUMENTS         _unparsed_args
  )

  if(_unparsed_args)
    message(WARNING "Unparsed arguments `${_unparsed_args}' for target `${_name}'")
  endif()

  get_target_property(_type ${_name} TYPE)

  if(_group)
    sloth_target_group("${_group}" "${_name}")
  endif()

  set_target_properties("${_name}"
    PROPERTIES
      EXCLUDE_FROM_ALL ${_exclude_from_all}
      EXCLUDE_FROM_DEFAULT_BUILD ${_exclude_from_default_build}
  )

  if(_type MATCHES "INTERFACE_LIBRARY")
    set(_scope "INTERFACE")
  else()
    set(_scope "PUBLIC")
  endif()

  if(_cflags)
    target_compile_options("${_name}" ${_scope} ${_cflags})
  endif()

  if(_defines)
    target_compile_definitions("${_name}" ${_scope} ${_defines})
  endif()

  if(_includes)
    sloth_list_filename_component(_includes ABSOLUTE ${_includes})
    target_include_directories("${_name}" ${_scope} ${_includes})
  endif()

  if(_link_libs)
    target_link_libraries("${_name}" ${_scope} ${_link_libs})
  endif()

  if(_depends)
    add_dependencies("${_name}" ${_depends})
  endif()
endfunction()

function(sloth_add_alias _name _target)
  if(TARGET ${_name})
    message(SEND_ERROR "Can not add alias ${_name}, target with name ${_name} already exists.")
  elseif(NOT TARGET ${_target})
    message(SEND_ERROR "Can not add alias ${_name}, target ${_target} does not exists.")
  else()
    get_target_property(_type ${_target} TYPE)
    if(_type MATCHES "^(STATIC|MODULE|SHARED|INTERFACE)_LIBRARY$")
      add_library(${_name} ALIAS ${_target})
    elseif(_type MATCHES "^EXECUTABLE$")
      add_executable(${_name} ALIAS ${_target})
    else()
      message(SEND_ERROR "Can not add alias ${_name} for target ${_target} of type ${_type}.")
    endif()
  endif()
endfunction()

function(sloth_select_alias _name)
  set(_state NEUTRAL)
  set(_default)
  set(_condition)
  set(_found NO)
  set(_target)

  foreach(_word IN LISTS ARGN)
    if(_state STREQUAL NEUTRAL AND _word STREQUAL DEFAULT)
      set(_state DEFAULT)
    elseif(_state STREQUAL DEFAULT)
      set(_state NEUTRAL)
      set(_default ${_word})
    elseif(_state STREQUAL NEUTRAL AND _word STREQUAL WHEN)
      set(_state WHEN)
    elseif(_state STREQUAL WHEN AND _word STREQUAL SELECT)
      set(_state SELECT)
    elseif(_state STREQUAL WHEN)
      list(APPEND _condition ${_word})
    elseif(_state STREQUAL SELECT)
      set(_state NEUTRAL)
      if(${_condition})
        set(_found YES)
        set(_target ${_word})
        break()
      endif()
      set(_condition)
    endif()
  endforeach()

  if(_found AND _target)
    sloth_add_alias(${_name} ${_target})
  elseif(NOT _found AND _default)
    sloth_add_alias(${_name} ${_default})
  endif()
endfunction()

function(sloth_add_object _name)
  sloth_parse_target_arguments("${ARGN}"
    SOURCES              _src
  )

  sloth_list_filename_component(_abssrc ABSOLUTE ${_src})
  add_library("${_name}" OBJECT ${_abssrc})
  sloth_target_setup("${_name}" ${ARGN})
endfunction()

function(sloth_add_interface _name)
  if(CMAKE_VERSION VERSION_GREATER 2.8.12.20131009)
    add_library("${_name}" INTERFACE)
  else()
    # emulate INTERFACE target
    set(_dummysrc "${CMAKE_CURRENT_BINARY_DIR}/_dummy.c")
    file(WRITE "${_dummysrc}" "/* empty dummy file. */\n")
    add_library("${_name}" STATIC ${_dummysrc})
  endif()
  sloth_target_setup("${_name}" ${ARGN})
endfunction()

function(sloth_add_library _name)
  sloth_parse_target_arguments("${ARGN}"
    STATIC               _static
    SHARED               _shared
    MODULE               _module
    SOURCES              _src
    COMPONENT            _comp
    EXCLUSE_FROM_INSTALL _noinst
  )
  if(_module)
    set(_type "MODULE")
  elseif(_shared)
    set(_type "SHARED")
  elseif(_static)
    set(_type "STATIC")
  else()
    set(_type "")
  endif()

  sloth_list_filename_component(_abssrc ABSOLUTE ${_src})
  add_library("${_name}" ${_type} ${_abssrc})
  sloth_target_setup("${_name}" ${ARGN})

  if(NOT _noinst)
    sloth_set_iff(_comp _comp _comp "library")
    install(TARGETS "${_name}" # EXPORT "${_name}Targets"
      RUNTIME DESTINATION bin COMPONENT "${_comp}"
      LIBRARY DESTINATION lib COMPONENT "${_comp}"
      ARCHIVE DESTINATION lib/static COMPONENT "${_comp}"
      RESOURCE DESTINATION share COMPONENT "${_comp}"
      PUBLIC_HEADER DESTINATION include COMPONENT "${_comp}"
    )
    #install(EXPORT "${_name}Targets"
    #  FILE "${_name}Targets.cmake"
    #  DESTINATION "CMake"
    #)
  endif()
endfunction()

function(sloth_import_library _name)
  sloth_parse_target_arguments("${ARGN}"
    STATIC               _static
    SHARED               _shared
    MODULE               _module
    UNKNOWN              _unknown
    GLOBAL               _global
    IMPORTED_LOCATION    _imported_location
  )
  if(_module)
    set(_type "MODULE")
  elseif(_shared)
    set(_type "SHARED")
  elseif(_static)
    set(_type "STATIC")
  else()
    set(_type "UNKNOWN")
  endif()

  sloth_set_iff(_global _global "GLOBAL" "")

  add_library("${_name}" ${_type} IMPORTED ${_abssrc})
  set_target_properties("${_name}" PROPERTIES
    IMPORTED_LOCATION "${_imported_location}"
  )
  sloth_target_setup("${_name}" ${ARGN})
endfunction()

function(sloth_add_executable _name)
  sloth_parse_target_arguments("${ARGN}"
    SOURCES              _src
    WIN32                _win32
    MACOSX_BUNDLE        _macosx_bundle
    COMPONENT            _comp
    EXCLUSE_FROM_INSTALL _noinst
  )

  if(_win32)
    set(_win32 "WIN32")
  else()
    set(_win32 "")
  endif()

  if(_macosx_bundle)
    set(_macosx_bundle "MACOSX_BUNDLE")
  else()
    set(_macosx_bundle "")
  endif()

  sloth_list_filename_component(_abssrc ABSOLUTE ${_src})

  add_executable("${_name}" "${_win32}" "${_macosx_bundle}" ${_abssrc})
  sloth_target_setup("${_name}" ${ARGN})

  if(NOT _noinst)
    sloth_set_iff(_comp _comp _comp "executable")
    install(TARGETS "${_name}"
      RUNTIME DESTINATION bin COMPONENT "${_comp}"
      RESOURCE DESTINATION share COMPONENT "${_comp}"
    )
  endif()
endfunction()

function(sloth_import_executable _name)
  sloth_parse_target_arguments("${ARGN}"
    SOURCES              _src
    WIN32                _win32
    MACOSX_BUNDLE        _macosx_bundle
    IMPORTED_LOCATION    _imported_location
  )

  if(_win32)
    set(_win32 "WIN32")
  else()
    set(_win32 "")
  endif()

  if(_macosx_bundle)
    set(_macosx_bundle "MACOSX_BUNDLE")
  else()
    set(_macosx_bundle "")
  endif()

  sloth_set_iff(_global _global "GLOBAL" "")

  add_executable("${_name}" IMPORTED ${_global})
  set_target_properties("${_name}" PROPERTIES
    IMPORTED_LOCATION "${_imported_location}"
  )
  sloth_target_setup("${_name}" ${ARGN})
endfunction()

function(sloth_add_test _name)
  sloth_parse_target_arguments("${ARGN}"
    SOURCES           _src
    ARGS              _args
    CONFIGURATIONS    _cfgs
    WORKING_DIRECTORY _wdir
  )
  sloth_list_filename_component(_abssrc ABSOLUTE ${_src})
  add_executable("${_name}" EXCLUDE_FROM_ALL ${_abssrc})
  if(NOT TARGET check)
    add_custom_target(check ${CMAKE_CTEST_COMMAND} -C $<CONFIGURATION> -VV)
  endif()
  add_dependencies(check "${_name}")
  sloth_target_setup("${_name}" ${ARGN})
  add_test(NAME "${_name}"
    COMMAND "${_name}" ${_args}
    CONFIGURATIONS ${_cfgs}
    WORKING_DIRECTORY ${_wdir}
  )
endfunction()

if(POLICY CMP022)
  cmake_policy(POP)
endif()

