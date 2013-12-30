#
# SlothPackage.cmake - Defines high level cmake package function.
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

if(_SLOTH_PACKAGE_CMAKE_INCLUDED)
  return()
endif()
set(_SLOTH_PACKAGE_CMAKE_INCLUDED 1)

include(CMakeParseArguments)
include(CMakePackageConfigHelpers)

function(sloth_parse_package_arguments _in)
  set(_flags
    EXCLUSE_FROM_INSTALL
  )

  set(_opts
    NAME
    NAMESPACE
    EXPORT_SET
    COMPONENT
    INSTALL_DESTINATION
    VERSION
    COMPATIBILITY
  )

  set(_args
    TARGETS
    INCLUDE_DIRECTORIES
    REQUIRES
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

function(sloth_package)
  sloth_parse_package_arguments("${ARGN}"
    NAME                       _name
    NAMESPACE                  _namespace
    EXPORT_SET                 _export_set
    COMPONENT                  _comp
    TARGETS                    _targets
    REQUIRES                   _reqs
    VERSION                    _version
    COMPATIBILITY              _compat
    INCLUDE_DIRECTORIES        _incdirs
  )

  if(_unparsed_args)
    message(WARNING "Unparsed arguments `${_unparsed_args}' for package `${_name}'")
  endif()

  if(NOT _name)
    set(_name ${PROJECT_NAME})
  endif()

  if(NOT _version)
    get_property(_version GLOBAL PROPERTY ${_name}_VERSION)
  endif()

  if(NOT _compat)
    get_property(_compat GLOBAL PROPERTY ${_name}_COMPATIBILITY)
    if(NOT _compat)
      set(_compat "ExactVersion")
    endif()
  endif()

  if(NOT _namespace)
    get_property(_namespace GLOBAL PROPERTY ${_name}_NAMESPACE)
  endif()

  if(NOT _reqs)
    get_property(_reqs GLOBAL PROPERTY ${_name}_REQUIRES)
  endif()

  if(NOT _comp)
    set(_comp ${_name})
  endif()

  if(NOT _export_set)
    set(_export_set ${_name})
  endif()

  set(_path_vars)

  set(_targets_cmake        "${_export_set}Targets.cmake")
  set(_config_cmake_in      "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_name}Config.cmake.in")
  set(_export_dir           "${CMAKE_CURRENT_BINARY_DIR}")
  set(_export_config_cmake  "${_export_dir}/${_name}Config.cmake")
  set(_install_config_cmake "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${_name}Config.cmake")
  set(_config_version_cmake "${CMAKE_CURRENT_BINARY_DIR}/${_name}ConfigVersion.cmake")
  set(_pkg_dest             "share/${_name}/cmake")

  set_property(GLOBAL APPEND PROPERTY ${_name}_PROVIDES ${_targets})

  # TODO: print warning for targets which are not build by all target

  file(WRITE ${_config_cmake_in}
    "@PACKAGE_INIT@\n"
    "\n"
    "foreach(_dep IN ITEMS @DEPENDENCIES@)\n"
    "  if(_dep MATCHES \"\\\\/[0-9]+(\\\\.[0-9]+)*\")\n"
    "    string(REGEX REPLACE \"(.*)\\\\/[0-9]+(\\\\.[0-9]+)*\" \"\\\\1\" _depname \"\${_dep}\")\n"
    "    string(REGEX REPLACE \".*\\\\/([0-9]+(\\\\.[0-9]+)*)\" \"\\\\1\" _depversion \"\${_dep}\")\n"
    "  else()\n"
    "    set(_depname \${_dep})\n"
    "    set(_depversion)\n"
    "  endif()\n"
    "  find_dependency(\${_depname} \${_depversion})\n"
    "  unset(_depname)\n"
    "  unset(_depversion)\n"
    "endforeach()\n"
    "\n"
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/${_targets_cmake}\")\n"
    "\n"
  )

  set(DEPENDENCIES ${_reqs})
  configure_package_config_file(
    ${_config_cmake_in} ${_install_config_cmake}
    INSTALL_DESTINATION ${_pkg_dest}
    PATH_VARS ${_path_vars}
  )

  write_basic_package_version_file(
    ${_config_version_cmake}
    VERSION       ${_version}
    COMPATIBILITY ${_compat}
  )

  install(TARGETS ${_targets} EXPORT "${_export_set}"
    RUNTIME        DESTINATION bin                  COMPONENT "${_comp}"
    LIBRARY        DESTINATION lib                  COMPONENT "${_comp}"
    ARCHIVE        DESTINATION lib/static           COMPONENT "${_comp}-dev"
    PRIVATE_HEADER DESTINATION src/${_name}/include COMPONENT "${_comp}-dev"
    PUBLIC_HEADER  DESTINATION include              COMPONENT "${_comp}-dev"
    RESOURCE       DESTINATION share/${_name}       COMPONENT "${_comp}"
    INCLUDES       DESTINATION include
  )
  if(_incdirs)
    install(DIRECTORY ${_incdirs}
      DESTINATION include
      COMPONENT   "${_comp}-dev"
    )
  endif()

  install(EXPORT "${_export_set}"
    NAMESPACE "${_namespace}::"
    FILE "${_targets_cmake}"
    DESTINATION "${_pkg_dest}"
    COMPONENT   "${_comp}-dev"
  )

  install(FILES ${_install_config_cmake} ${_config_version_cmake}
    DESTINATION ${_pkg_dest}
    COMPONENT   "${_comp}-dev"
  )

  # export build dir
  if(CMAKE_VERSION VERSION_GREATER 2.8.12.20131224)
    # TODO: fix version of implementation
    # implemented in export-EXPORT-subcommand branch,
    # but not yet mearged in master
    export(EXPORT "${_export_set}"
      NAMESPACE "${_namespace}::"
      FILE "${CMAKE_CURRENT_BINARY_DIR}/${_targets_cmake}"
    )
  else()
    export(TARGETS ${_targets}
      NAMESPACE "${_namespace}::"
      FILE "${CMAKE_CURRENT_BINARY_DIR}/${_targets_cmake}"
    )
  endif()
  export(PACKAGE "${_name}")

  configure_package_config_file(
    ${_config_cmake_in} ${_export_config_cmake}
    INSTALL_DESTINATION ${_export_dir}
    PATH_VARS ${_path_vars}
  )

endfunction()

