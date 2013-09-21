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

function(sloth_target_requires _name)
  set(_properties
    COMPILE_OPTIONS
    COMPILE_DEFINITIONS
    INCLUDE_DIRECTORIES
    POSITION_INDEPENDENT_CODE
  )
  foreach(_req ${_requires})
    foreach(_prop ${_properties})
      set_property(TARGET "${_name}" APPEND PROPERTY
        "${_prop}" $<TARGET_PROPERTY:${_req},INTERFACE_${_prop}>)
      set_property(TARGET "${_name}" APPEND PROPERTY
        "INTERFACE_${_prop}" $<TARGET_PROPERTY:${_req},INTERFACE_${_prop}>)
    endforeach()

    # TODO: waiting for INTERFACE library type in CMake 2.8.13(?)
    #       UNKNOWN type is missused as a workaround
    set_property(TARGET "${_name}" APPEND PROPERTY
      LINK_LIBRARIES
      $<$<NOT:$<STREQUAL:$<TARGET_PROPERTY:${_req},TYPE>,UNKNOWN_LIBRARY>>:${_req}>
      $<$<STREQUAL:$<TARGET_PROPERTY:${_req},TYPE>,UNKNOWN_LIBRARY>:$<TARGET_PROPERTY:${_req},LINK_LIBRARIES>>
    )
  endforeach()
endfunction(sloth_target_requires)

function(sloth_target_setup _name)
  sloth_parse_target_arguments("${ARGN}"
    EXCLUDE_FROM_ALL                    _exclude_from_all
    EXCLUDE_FROM_DEFAULT_BUILD          _exclude_from_default_build
    GROUP                               _group
    CONFIGURATIONS                      _cfgs
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
    LINK_LIBRARIES                      _link_libs
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

  set(_target_private_cflags   ${_private_cflags}   ${_public_cflags})
  set(_target_interface_cflags ${_interface_cflags} ${_public_cflags})
  if(_target_private_cflags)
    #target_compile_options("${_name}" PRIVATE ${_target_private_cflags})
  endif()
  if(_target_interface_cflags)
    #target_compile_options("${_name}" INTERFACE ${_target_interface_cflags})
  endif()

  set(_target_private_def   ${_private_defs}   ${_public_defs})
  set(_target_interface_def ${_interface_defs} ${_public_defs})
  if(_target_private_defs)
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
  if(_target_private_includes)
    target_include_directories("${_name}" PRIVATE ${_target_private_includes})
  endif()
  if(_target_interface_includes)
    target_include_directories("${_name}" INTERFACE ${_target_interface_includes})
  endif()

  if(_link_libs)
    target_link_libraries("${_name}" ${_link_libs})
  endif()

  if(_depends)
    add_dependencies("${_name}" ${_depends})
  endif()

  sloth_target_requires("${_name}" ${_requires})
endfunction()

function(sloth_add_library _name)
  sloth_parse_target_arguments("${ARGN}"
    STATIC               _static
    SHARED               _shared
    MODULE               _module
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
  sloth_set_iff(_comp _comp _comp "library")
  sloth_list_filename_component(_abssrc ABSOLUTE ${_src})
  add_library("${_name}" ${_type} ${_abssrc})
  sloth_target_setup("${_name}" ${ARGN})
  if(NOT _noinst)
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
    REQUIRES             _req
    COMPONENT            _comp
    EXCLUSE_FROM_INSTALL _noinst
  )
  sloth_set_iff(_comp _comp _comp "executable")
  sloth_list_filename_component(_abssrc ABSOLUTE ${_src})
  add_executable("${_name}" ${_abssrc})
  sloth_target_setup("${_name}" ${ARGN})
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
  add_executable("${_name}" ${_abssrc})
  sloth_target_setup("${_name}" ${ARGN})
  add_test(NAME "${_name}"
    COMMAND "${_name}" ${_args}
    CONFIGURATIONS ${_cfgs}
    WORKING_DIRECTORY ${_wdir}
  )
endfunction()
