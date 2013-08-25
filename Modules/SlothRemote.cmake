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

  foreach(_k ${_keys} UNPARSED_ARGUMENTS)
    if("_a_${_k}")
      set("${_a_${_k}}" ${_arg_${_k}} PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

function(sloth_remote_git_clone _name)
  sloth_parse_remote_arguments("${ARGN}"
    GIT_REPOSITORY _git_repo
    GIT_TAG _git_tag
    DESTINATION _dest
  )

  execute_process(
    COMMAND "${GIT_EXECUTABLE}" clone "${_git_repo}" ${_dest}
    RESULT_VARIABLE _ec
  )
  if(_ec)
    message(FATAL_ERROR "SlothRemote: Failed to clone git repository `${_git_repo}'.")
  endif()

  execute_process(
    COMMAND "${GIT_EXECUTABLE}" checkout "${_git_tag}"
    WORKING_DIRECTORY "${_dest}"
    RESULT_VARIABLE _ec
    OUTPUT_QUIET
    ERROR_QUIET
  )
  if(_ec)
    message(FATA_ERROR "SlothRemote: Failed to checkout git tag `${_git_tag}'.")
  endif()

  if(EXISTS "${_dest}/.gitmodules")
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" submodule init
      WORKING_DIRECTORY "${_dest}"
      RESULT_VARIABLE _ec
    )
    if(_ec)
      message(FATA_ERROR "SlothRemote: Failed to initialize submodules of `${_name}'.")
    endif()

    execute_process(
      COMMAND "${GIT_EXECUTABLE}" submodule init --recursive
      WORKING_DIRECTORY "${_dest}"
      RESULT_VARIABLE _ec
    )
    if(_ec)
      message(FATA_ERROR "SlothRemote: Failed to update submodules of `${_name}'.")
    endif()
  endif()
endfunction()

function(sloth_remote_git_update _name)
  sloth_parse_remote_arguments("${ARGN}"
    GIT_REPOSITORY _git_repo
    GIT_TAG _git_tag
    DESTINATION _dest
  )

  execute_process(
    COMMAND "${GIT_EXECUTABLE}" rev-parse --verify "${_git_tag}"
    WORKING_DIRECTORY "${_dest}"
    RESULT_VARIABLE _ec
    OUTPUT_VARIABLE _tag_hash
  )
  if(_ec)
    message(FATAL_ERROR "SlothRemote: Failed to get hash of `${_name}' `${_git_tag}'.")
  endif()

  execute_process(
    COMMAND "${GIT_EXECUTABLE}" rev-parse --verify "HEAD"
    WORKING_DIRECTORY "${_dest}"
    RESULT_VARIABLE _ec
    OUTPUT_VARIABLE _head_hash
  )
  if(_ec)
    message(FATAL_ERROR "SlothRemote: Failed to get hash of `${_name}' HEAD.")
  endif()

  if(NOT ("${_tag_hash}" STREQUAL "${_head_hash}"))
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" diff-index --quiet HEAD
      WORKING_DIRECTORY "${_dest}"
      RESULT_VARIABLE _ec
      OUTPUT_QUIET
      ERROR_QUIET
    )
    if(_ec)
      set(_skip_update YES)
      message(WARNING "SlothRemote: git repository `${_name}' is out of sync but dirty. No changes made.")
    else()
      set(_skip_update NO)
    endif()

    if(NOT _skip_update)
      execute_process(
        COMMAND "${GIT_EXECUTABLE}" fetch
        WORKING_DIRECTORY "${_dest}"
        RESULT_VARIABLE _ec
      )
      if(_ec)
        message(FATAL_ERROR "SlothRemote: Failed to fetch git repository `${_git_repo}'.")
      endif()

      execute_process(
        COMMAND "${GIT_EXECUTABLE}" checkout "${_git_tag}"
        WORKING_DIRECTORY "${_dest}"
        RESULT_VARIABLE _ec
      )
      if(_ec)
        message(FATAL_ERROR "SlothRemote: Failed to checkout `${_git_tag}'.")
      endif()
      if(EXISTS "${_dest}/.gitmodules")
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" submodule init --recursive
          WORKING_DIRECTORY "${_dest}"
          RESULT_VARIABLE _ec
        )
        if(_ec)
          message(FATA_ERROR "SlothRemote: Failed to update submodules of `${_name}'.")
        endif()
      endif()
    endif()
  else()
    message(STATUS "SlothRemote: `${_name}' is up-to-date.")
  endif()
endfunction()

function(sloth_remote_git_fetch _name)
  sloth_parse_remote_arguments("${ARGN}"
    GIT_REPOSITORY _git_repo
    GIT_TAG _git_tag
    DESTINATION _dest
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

  if(NOT EXISTS "${_dest}")
    sloth_remote_git_clone(${_name} ${ARGN})
  else()
    sloth_remote_git_update(${_name} ${ARGN})
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
