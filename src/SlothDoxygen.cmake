#
# SlothDoxygen.cmake
#
# Adds a target to build the API documentation from source using Doxygen.
#
#   sloth_doxygen(name
#     OPTIONS ...
#   )
#
# or
#
#   sloth_doxygen(name
#     TARGETS target1 target2 ... targetN
#     [ OPTIONS ]
#   )
#
# For a list of available options see:
#   http://www.stack.nl/~dimitri/doxygen/manual/config.html

#=============================================================================
# Copyright (C) 2013 Kiron
#
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#=============================================================================

if(_SLOTH_DOXYGEN_CMAKE_INCLUDED)
  return()
endif()
set(_SLOTH_DOXYGEN_CMAKE_INCLUDED 1)

function(sloth_doxygen _name)
  if(NOT DEFINED DOXYGEN_FOUND)
    find_package(Doxygen QUIET)
  endif()

  if(NOT DOXYGEN_EXECUTABLE)
    add_custom_target("${_name}"
      COMMENT "Generating API disabled, could not find Doxygen"
    )
    return()
  endif()

  set(_args
    ABBREVIATE_BRIEF
    ALIASES
    ALLEXTERNALS
    ALPHABETICAL_INDEX
    ALWAYS_DETAILED_SEC
    AUTOLINK_SUPPORT
    BINARY_TOC
    BRIEF_MEMBER_DESC
    BUILTIN_STL_SUPPORT
    CALL_GRAPH
    CALLER_GRAPH
    CASE_SENSE_NAMES
    CHM_FILE
    CHM_INDEX_ENCODING
    CITE_BIB_FILES
    CLANG_ASSISTED_PARSING
    CLANG_OPTIONS
    CLASS_DIAGRAMS
    CLASS_GRAPH
    COLLABORATION_GRAPH
    COLS_IN_ALPHA_INDEX
    COMPACT_LATEX
    COMPACT_RTF
    CPP_CLI_SUPPORT
    CREATE_SUBDIRS
    DIRECTORY_GRAPH
    DISABLE_INDEX
    DISTRIBUTE_GROUP_DOC
    DOCBOOK_OUTPUT
    DOCSET_BUNDLE_ID
    DOCSET_FEEDNAME
    DOCSET_PUBLISHER_ID
    DOCSET_PUBLISHER_NAME
    DOT_CLEANUP
    DOT_FONTNAME
    DOT_FONTPATH
    DOT_FONTSIZE
    DOT_GRAPH_MAX_NODES
    DOT_IMAGE_FORMAT
    DOT_MULTI_TARGETS
    DOT_NUM_THREADS
    DOT_PATH
    DOT_TRANSPARENT
    DOTFILE_DIRS
    DOXYFILE_ENCODING
    ECLIPSE_DOC_ID
    ENABLE_PREPROCESSING
    ENABLED_SECTIONS
    ENUM_VALUES_PER_LINE
    EXAMPLE_PATH
    EXAMPLE_PATTERNS
    EXAMPLE_RECURSIVE
    EXCLUDE
    EXCLUDE_PATTERNS
    EXCLUDE_SYMBOLS
    EXCLUDE_SYMLINKS
    EXPAND_AS_DEFINED
    EXPAND_ONLY_PREDEF
    EXT_LINKS_IN_WINDOW
    EXTENSION_MAPPING
    EXTERNAL_GROUPS
    EXTERNAL_PAGES
    EXTERNAL_SEARCH
    EXTERNAL_SEARCH_ID
    EXTRA_PACKAGES
    EXTRA_SEARCH_MAPPINGS
    EXTRACT_ALL
    EXTRACT_ANON_NSPACES
    EXTRACT_LOCAL_CLASSES
    EXTRACT_LOCAL_METHODS
    EXTRACT_PACKAGE
    EXTRACT_PRIVATE
    EXTRACT_STATIC
    FILE_PATTERNS
    FILE_VERSION_FILTER
    FILTER_PATTERNS
    FILTER_SOURCE_FILES
    FILTER_SOURCE_PATTERNS
    FORCE_LOCAL_INCLUDES
    FORMULA_FONTSIZE
    FORMULA_TRANSPARENT
    FULL_PATH_NAMES
    GENERATE_AUTOGEN_DEF
    GENERATE_BUGLIST
    GENERATE_CHI
    GENERATE_DEPRECATEDLIST
    GENERATE_DOCBOOK
    GENERATE_DOCSET
    GENERATE_ECLIPSEHELP
    GENERATE_HTML
    GENERATE_HTMLHELP
    GENERATE_LATEX
    GENERATE_LEGEND
    GENERATE_MAN
    GENERATE_PERLMOD
    GENERATE_QHP
    GENERATE_RTF
    GENERATE_TAGFILE
    GENERATE_TESTLIST
    GENERATE_TODOLIST
    GENERATE_TREEVIEW
    GENERATE_XML
    GRAPHICAL_HIERARCHY
    GROUP_GRAPHS
    HAVE_DOT
    HHC_LOCATION
    HIDE_FRIEND_COMPOUNDS
    HIDE_IN_BODY_DOCS
    HIDE_SCOPE_NAMES
    HIDE_UNDOC_CLASSES
    HIDE_UNDOC_MEMBERS
    HIDE_UNDOC_RELATIONS
    HTML_ALIGN_MEMBERS
    HTML_COLORSTYLE_GAMMA
    HTML_COLORSTYLE_HUE
    HTML_COLORSTYLE_SAT
    HTML_DYNAMIC_SECTIONS
    HTML_EXTRA_FILES
    HTML_EXTRA_STYLESHEET
    HTML_FILE_EXTENSION
    HTML_FOOTER
    HTML_HEADER
    HTML_INDEX_NUM_ENTRIES
    HTML_OUTPUT
    HTML_STYLESHEET
    HTML_TIMESTAMP
    IDL_PROPERTY_SUPPORT
    IGNORE_PREFIX
    IMAGE_PATH
    INCLUDE_FILE_PATTERNS
    INCLUDE_GRAPH
    INCLUDE_PATH
    INCLUDED_BY_GRAPH
    INHERIT_DOCS
    INLINE_GROUPED_CLASSES
    INLINE_INFO
    INLINE_INHERITED_MEMB
    INLINE_SIMPLE_STRUCTS
    INLINE_SOURCES
    INPUT
    INPUT_ENCODING
    INPUT_FILTER
    INTERACTIVE_SVG
    INTERNAL_DOCS
    JAVADOC_AUTOBRIEF
    LATEX_BATCHMODE
    LATEX_BIB_STYLE
    LATEX_CMD_NAME
    LATEX_EXTRA_FILES
    LATEX_FOOTER
    LATEX_HEADER
    LATEX_HIDE_INDICES
    LATEX_OUTPUT
    LATEX_SOURCE_CODE
    LAYOUT_FILE
    LOOKUP_CACHE_SIZE
    MACRO_EXPANSION
    MAKEINDEX_CMD_NAME
    MAN_EXTENSION
    MAN_LINKS
    MAN_OUTPUT
    MARKDOWN_SUPPORT
    MATHJAX_EXTENSIONS
    MATHJAX_FORMAT
    MATHJAX_RELPATH
    MATHJAX_CODEFILE
    MAX_DOT_GRAPH_DEPTH
    MAX_INITIALIZER_LINES
    MSCFILE_DIRS
    MSCGEN_PATH
    MULTILINE_CPP_IS_BRIEF
    OPTIMIZE_FOR_FORTRAN
    OPTIMIZE_OUTPUT_FOR_C
    OPTIMIZE_OUTPUT_JAVA
    OPTIMIZE_OUTPUT_VHDL
    OUTPUT_DIRECTORY
    OUTPUT_LANGUAGE
    PAPER_TYPE
    PDF_HYPERLINKS
    PERL_PATH
    PERLMOD_LATEX
    PERLMOD_MAKEVAR_PREFIX
    PERLMOD_PRETTY
    PREDEFINED
    PROJECT_BRIEF
    PROJECT_LOGO
    PROJECT_NAME
    PROJECT_NUMBER
    QCH_FILE
    QHG_LOCATION
    QHP_CUST_FILTER_ATTRS
    QHP_CUST_FILTER_NAME
    QHP_NAMESPACE
    QHP_SECT_FILTER_ATTRS
    QHP_VIRTUAL_FOLDER
    QT_AUTOBRIEF
    QUIET
    RECURSIVE
    REFERENCED_BY_RELATION
    REFERENCES_LINK_SOURCE
    REFERENCES_RELATION
    REPEAT_BRIEF
    RTF_EXTENSIONS_FILE
    RTF_HYPERLINKS
    RTF_OUTPUT
    RTF_STYLESHEET_FILE
    SEARCH_INCLUDES
    SEARCHDATA_FILE
    SEARCHENGINE
    SEARCHENGINE_URL
    SEPARATE_MEMBER_PAGES
    SERVER_BASED_SEARCH
    SHORT_NAMES
    SHOW_FILES
    SHOW_INCLUDE_FILES
    SHOW_NAMESPACES
    SHOW_USED_FILES
    SIP_SUPPORT
    SKIP_FUNCTION_MACROS
    SORT_BRIEF_DOCS
    SORT_BY_SCOPE_NAME
    SORT_GROUP_NAMES
    SORT_MEMBER_DOCS
    SORT_MEMBERS_CTORS_1ST
    SOURCE_BROWSER
    STRICT_PROTO_MATCHING
    STRIP_CODE_COMMENTS
    STRIP_FROM_INC_PATH
    STRIP_FROM_PATH
    SUBGROUPING
    TAB_SIZE
    TAGFILES
    TCL_SUBST
    TEMPLATE_RELATIONS
    TOC_EXPAND
    TREEVIEW_WIDTH
    TYPEDEF_HIDES_STRUCT
    UML_LIMIT_NUM_FIELDS
    UML_LOOK
    USE_HTAGS
    USE_MATHJAX
    USE_MDFILE_AS_MAINPAGE
    USE_PDFLATEX
    VERBATIM_HEADERS
    WARN_FORMAT
    WARN_IF_DOC_ERROR
    WARN_IF_UNDOCUMENTED
    WARN_LOGFILE
    WARN_NO_PARAMDOC
    WARNINGS
    XML_DTD
    XML_OUTPUT
    XML_PROGRAMLISTING
    XML_SCHEMA
  )

  set(_default_PROJECT_NAME         "\"${PROJECT_NAME}\"")
  set(_default_OUTPUT_DIRECTORY     "\"${CMAKE_CURRENT_BINARY_DIR}/doc\"")
  set(_default_STRIP_FROM_INC_PATH  "\"${CMAKE_SOURCE_DIR}\"")
  set(_default_STRIP_FROM_PATH      "\"${CMAKE_SOURCE_DIR}\"")
  set(_default_QUIET                YES)
  set(_default_WARN_IF_UNDOCUMENTED NO)
  set(_default_GENERATE_LATEX       NO)
  set(_default_GENERATE_HTML        YES)
  set(_default_GENERATE_XML         NO)

  cmake_parse_arguments("_doxygen" "" "" "TARGETS;${_args}" ${ARGN})

  set(_doxyfile ${CMAKE_CURRENT_BINARY_DIR}/${_name}.doxyfile)

  file(WRITE  ${_doxyfile} "# This file was auto-generated, do NOT edit\n")
  file(APPEND ${_doxyfile} "# Instead edit ${CMAKE_CURRENT_LIST_FILE}\n\n")

  if(_doxygen_TARGETS)
    set(_input)
    foreach(_target IN LISTS _doxygen_TARGETS)
      get_target_property(_src ${_target} SOURCES)
      list(APPEND _input ${_src})
    endforeach()
    string(REGEX REPLACE ";" " " _input_value "${_input}")
    file(APPEND ${_doxyfile} "INPUT = ${_input_value}\n\n")
  endif()

  foreach(_param IN LISTS _args)
    if(DEFINED "_doxygen_${_param}")
      set(_param_value "${_doxygen_${_param}}")
    elseif(DEFINED "_default_${_param}")
      set(_param_value "${_default_${_param}}")
    endif()
    if(DEFINED _param_value)
      string(REGEX REPLACE ";" " " _param_value "${_param_value}")
      if(_doxygen_TARGETS AND _param STREQUAL INPUT)
        set(_op "+=")
      else()
        set(_op "=")
      endif()
      file(APPEND ${_doxyfile} "${_param} ${_op} ${_param_value}\n\n")
      unset(_param_value)
    endif()
  endforeach()

  add_custom_target("${_name}"
    ${DOXYGEN_EXECUTABLE} "${_doxyfile}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating API documentation using Doxygen"
    VERBATIM
  )

  set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES
    "${_doxygen_OUTPUT_DIRECTORY}"
  )

endfunction()