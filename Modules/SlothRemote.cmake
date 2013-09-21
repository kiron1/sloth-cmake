#
# SlothRemote.cmake - Fetch remote projects at configuration time.
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

function(sloth_parse_remote_arguments _in)
  set(_flags
    ENABLED
    CREATE_TARGET
    ALL
  )

  set(_opts
    GIT_REPOSITORY
    GIT_TAG
    DESTINATION
    SUMMARY
  )

  set(_args
  )

  set(_keys ${_flags} ${_opts} ${_args})

  cmake_parse_arguments("_a" "" "${_keys}" "" ${ARGN})

  cmake_parse_arguments("_arg"
    "${_flags}"
    "${_opts}"
    "${_args}"
    ${_in}
  )

  if(_arg_ALL)
    set(_arg_ALL "ALL")
  else()
    set(_arg_ALL "")
   endif()

  foreach(_k ${_keys} UNPARSED_ARGUMENTS)
    if("_a_${_k}")
      set("${_a_${_k}}" ${_arg_${_k}} PARENT_SCOPE)
    endif()
  endforeach()
endfunction()


function(sloth_remote_git_fetch _name)
  sloth_parse_remote_arguments("${ARGN}"
    GIT_REPOSITORY      _git_repo
    GIT_TAG             _git_tag
    DESTINATION         _dest
    CREATE_TARGET       _create_target
    ALL                 _all
  )

  if(NOT DEFINED GIT_FOUND)
    find_package(Git QUIET)
  endif()

  if(NOT GIT_EXECUTABLE)
    message(SEND_ERROR "SlothRemote: Git not found to fetch git remote `${_name}'.")
  endif()

  if("${_git_repo}" STREQUAL "" OR "${_git_tag}" STREQUAL "")
    message(SEND_ERROR "SlothRemote: GIT_REPOSITORY and GIT_TAG should not be empty for git remote `${_name}'.")
  endif()

  set(_script "${CMAKE_CURRENT_BINARY_DIR}/SlothRemote${_name}.cmake")
  sloth_configure(
    "${SLOTH_RESOUCES_DIR}/SlothRemoteGit.cmake.in"
    "${_script}"
    "NAME"                ${_name}
    "GIT_REPOSITORY"      ${_git_repo}
    "GIT_TAG"             ${_git_tag}
    "DESTINATION"         ${_dest}
  )

  execute_process(COMMAND "${CMAKE_COMMAND}" -P "${_script}")

  if(_create_target)
    add_custom_target("${_name}" ${_all}
      COMMAND "${CMAKE_COMMAND}" -P "${_script}"
      COMMENT "Updating remote `${_name}'."
    )
  endif()
endfunction()

function(sloth_add_remote _name)
  sloth_parse_remote_arguments("${ARGN}"
    GIT_REPOSITORY      _git_repo
    GIT_TAG             _git_tag
    DESTINATION         _dest
    SUMMARY             _summary
    ENABLED             _enabled
    UNPARSED_ARGUMENTS  _unparsed_args
  )

  if(_unparsed_args)
    message(WARNING "Unparsed arguments `${_unparsed_args}' for library declaration `${_name}'")
  endif()

  option("SlothRemote_${_name}" "${_summary}" ${_enabled})
  mark_as_advanced("SlothRemote_${_name}")

  if("SlothRemote_${_name}")
    if(_git_repo)
      sloth_remote_git_fetch("${_name}" ${ARGN})
    elseif(_svn_repo)
      # TODO: not yet implemented
      sloth_remote_svn_fetch("${_name}" ${ARGN})
    endif()
  endif()

endfunction()
