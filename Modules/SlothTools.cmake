#
# SlothTools.cmake - Cmake Tool functions.
#

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================


function(sloth_set_iff _var)
  set(_a ${ARGN})
  list(GET _a -2 _yes)
  list(GET _a -1 _no)
  list(REMOVE_AT _a -1 -2)
  if(${_a})
    set(${_var} ${_yes} PARENT_SCOPE)
  else()
    set(${_var} ${_no} PARENT_SCOPE)
  endif()
endfunction()

function(sloth_list_match _var _expr)
  foreach(_s ${ARGN})
    if("${_s}" MATCHES "${_expr}")
      list(APPEND _lst "${_s}")
    endif()
  endforeach()
  set(${_var} ${_lst} PARENT_SCOPE)
endfunction()

function(sloth_list_replace _var _expr _repl)
  foreach(_s ${ARGN})
    string(REGEX REPLACE "${_expr}" "${_repl}" _res ${_s})
    list(APPEND _lst "${_res}")
  endforeach()
  set(${_var} ${_lst} PARENT_SCOPE)
endfunction()

function(sloth_list_string _var _cmd)
  foreach(_s ${ARGN})
    string("${_cmd}" ${_s} _res)
    list(APPEND _lst "${_res}")
  endforeach()
  set(${_var} ${_lst} PARENT_SCOPE)
endfunction()

function(sloth_list_filename_component _var _comp)
  foreach(_s ${ARGN})
    get_filename_component(_res ${_s} "${_comp}")
    list(APPEND _lst "${_res}")
  endforeach()
  set(${_var} ${_lst} PARENT_SCOPE)
endfunction()

function(sloth_target_group _group)
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)
  foreach(_target ${ARGN})
    if(TARGET "${_target}")
      set_target_properties("${_target}" PROPERTIES FOLDER "${_group}")
    endif()
  endforeach()
endfunction()

