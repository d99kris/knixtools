# Project
cmake_minimum_required(VERSION 3.14...3.22 FATAL_ERROR)
project(knixtools NONE)
message(STATUS "Using cmake ${CMAKE_VERSION}")

# Macro
set(UNINSTALL_FILES "")
macro(add_script name)
  configure_file(bin/${name} ${CMAKE_CURRENT_BINARY_DIR}/${name} COPYONLY)
  install(PROGRAMS bin/${name} DESTINATION bin)
  list(APPEND UNINSTALL_FILES
    "${CMAKE_INSTALL_PREFIX}/bin/${name}"
  )
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/doc/${name}.1")
    install(FILES doc/${name}.1 DESTINATION share/man/man1)
    list(APPEND UNINSTALL_FILES
      "${CMAKE_INSTALL_PREFIX}/share/man/man1/${name}.1"
    )
  endif()
endmacro()

# Scripts
add_script(7zcd)
add_script(7zdec)
add_script(7zenc)
add_script(7zfind)
add_script(7zlist)
add_script(7zopen)
add_script(7zpass)
add_script(agentusage)
add_script(commoncrawl)
add_script(cvc)
add_script(liveinstall)
add_script(nspell-gpt)
add_script(pipdeps)
add_script(tenv)
add_script(sget)

# Uninstall
set(UNINSTALL_COMMANDS "")
foreach(f ${UNINSTALL_FILES})
  list(APPEND UNINSTALL_COMMANDS COMMAND "${CMAKE_COMMAND}" -E remove "${f}")
endforeach()
add_custom_target(uninstall ${UNINSTALL_COMMANDS})

