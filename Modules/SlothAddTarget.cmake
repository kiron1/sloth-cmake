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

function(sloth_target_setup _name)
  sloth_parse_target_arguments("${ARGN}"
    EXCLUDE_FROM_ALL                    _exclude_from_all
    EXCLUDE_FROM_DEFAULT_BUILD          _exclude_from_default_build
    GROUP                               _group
    CONFIGURATIONS                      _cfgs
    INTERFACE                           _interface
    SOURCES                             _src
    PUBLIC_COMPILE_OPTIONS              _public_cflags
    INTERFACE_COMPILE_OPTIONS           _interface_cflags
    PRIVATE_COMPILE_OPTIONS             _private_cflags
    PUBLIC_COMPILE_DEFINITIONS          _public_defs
    INTERFACE_COMPILE_DEFINITIONS       _interface_defs
    PRIVATE_COMPILE_DEFINITIONS         _private_defs
    PUBLIC_INCLUDE_DIRECTORIES          _public_includes
    INTERFACE_INCLUDE_DIRECTORIES       _interface_includes
    PRIVATE_INCLUDE_DIRECTORIES         _private_includes
    PUBLIC_LINK_LIBRARIES               _public_link_libs
    INTERFACE_LINK_LIBRARIES            _interface_link_libs
    PRIVATE_LINK_LIBRARIES              _private_link_libs
    REQUIRES                            _requires
    DEPENDS                             _depends
    UNPARSED_ARGUMENTS                  _unparsed_args
  )

  if(_unparsed_args)
    message(WARNING "Unparsed arguments `${_unparsed_args}' for target `${_name}'")
  endif()

  if(_group)
    sloth_target_group("${_group}" "${_name}")
  endif()

  set_target_properties("${_name}"
    PROPERTIES
      EXCLUDE_FROM_ALL ${_exclude_from_all}
      EXCLUDE_FROM_DEFAULT_BUILD ${_exclude_from_default_build}
  )

  if(_interface)
    set(_with_private NO)
  else()
    set(_with_private YES)
  endif()

  set(_target_private_cflags   ${_private_cflags}   ${_public_cflags})
  set(_target_interface_cflags ${_interface_cflags} ${_public_cflags})
  if(_with_private AND _target_private_cflags)
    target_compile_options("${_name}" PRIVATE ${_target_private_cflags})
  endif()
  if(_target_interface_cflags)
    target_compile_options("${_name}" INTERFACE ${_target_interface_cflags})
  endif()

  set(_target_private_defs   ${_private_defs}   ${_public_defs})
  set(_target_interface_defs ${_interface_defs} ${_public_defs})
  if(_with_private AND _target_private_defs)
    target_compile_definitions("${_name}" PRIVATE ${_target_private_defs})
  endif()
  if(_target_interface_defs)
    target_compile_definitions("${_name}" INTERFACE ${_target_interface_defs})
  endif()

  sloth_list_filename_component(_public_includes    ABSOLUTE ${_public_includes})
  sloth_list_filename_component(_interface_includes ABSOLUTE ${_interface_includes})
  sloth_list_filename_component(_private_includes   ABSOLUTE ${_private_includes})
  set(_target_private_includes   ${_private_includes}   ${_public_includes})
  set(_target_interface_includes ${_interface_includes} ${_public_includes})
  if(_with_private AND _target_private_includes)
    target_include_directories("${_name}" PRIVATE ${_target_private_includes})
  endif()
  if(_target_interface_includes)
    target_include_directories("${_name}" INTERFACE ${_target_interface_includes})
  endif()

  set(_target_private_link_libs   ${_private_link_libs}   ${_public_link_libs} ${_requires})
  set(_target_interface_link_libs ${_interface_link_libs} ${_public_link_libs} ${_requires})
  if(_with_private AND _target_private_link_libs)
    target_link_libraries("${_name}" PRIVATE ${_target_private_link_libs})
  endif()
  if(_target_interface_link_libs)
    target_link_libraries("${_name}" INTERFACE ${_target_interface_link_libs})
  endif()

  if(_depends)
    add_dependencies("${_name}" ${_depends})
  endif()
endfunction()

function(sloth_add_library _name)
  sloth_parse_target_arguments("${ARGN}"
    STATIC               _static
    SHARED               _shared
    MODULE               _module
    UNKNOWN              _unknown
    GLOBAL               _global
    ALIAS                _alias
    OBJECT               _object
    INTERFACE            _interface
    IMPORTED             _imported
    IMPORTED_LOCATION    _imported_location
    SOURCES              _src
    REQUIRES             _req
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

  if(_interface AND _unknown)
    set(_type "UNKNOWN")
  endif()

  sloth_set_iff(_global _global "GLOBAL" "")

  sloth_set_iff(_comp _comp _comp "library")
  if(_src)
    sloth_list_filename_component(_abssrc ABSOLUTE ${_src})
  endif()

  if(_imported AND _type AND _imported_location AND NOT _src)
    add_library("${_name}" IMPORTED "${_global}")
    set_target_properties("${_name}" PROPERTIES
      IMPORTED_LOCATION "${_imported_location}"
    )
  elseif(_object AND _src AND NOT _type)
    add_library("${_name}" OBJECT ${_abssrc})
  elseif(_interface AND NOT _src)
    if(CMAKE_VERSION VERSION_GREATER 2.8.12.20131009)
      add_library("${_name}" INTERFACE)
    else()
      # emulate INTERFACE target
      set(_dummysrc "${CMAKE_CURRENT_BINARY_DIR}/_dummy.c")
      file(WRITE "${_dummysrc}" "\n")
      add_library("${_name}" STATIC ${_dummysrc})
    endif()
  elseif(_src AND NOT _imported AND NOT _interface AND NOT _unknown)
    add_library("${_name}" ${_type} ${_abssrc})
  else()
    message(FATAL_ERROR "Bad usage of sloth_add_library command")
  endif()

  sloth_target_setup("${_name}" ${ARGN})

  if(_alias)
    add_library("${_alias}" ALIAS "${_name}" )
  endif()

  if(NOT _noinst AND NOT _interface)
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

function(sloth_add_executable _name)
  sloth_parse_target_arguments("${ARGN}"
    SOURCES              _src
    WIN32                _win32
    MACOSX_BUNDLE        _macosx_bundle
    ALIAS                _alias
    OBJECT               _object
    IMPORTED             _imported
    IMPORTED_LOCATION    _imported_location
    REQUIRES             _req
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

  sloth_set_iff(_comp _comp _comp "executable")
  sloth_list_filename_component(_abssrc ABSOLUTE ${_src})

  if(_imported)
    add_executable("${_name}" IMPORTED "${_global}")
    set_target_properties("${_name}" PROPERTIES
      IMPORTED_LOCATION "${_imported_location}"
    )
  elseif(_src)
    add_executable("${_name}" "${_win32}" "${_macosx_bundle}" ${_abssrc})
  else()
    message(FATAL_ERROR "Bad usage of sloth_add_executable command")
  endif()

  sloth_target_setup("${_name}" ${ARGN})

  if(_alias)
    add_library("${_alias}" ALIAS "${_name}" )
  endif()

  if(NOT _noinst)
    install(TARGETS "${_name}"
      RUNTIME DESTINATION bin COMPONENT "${_comp}"
      RESOURCE DESTINATION share COMPONENT "${_comp}"
    )
  endif()
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
