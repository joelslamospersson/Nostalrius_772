# Find LuaJIT
find_path(LUAJIT_INCLUDE_DIR luajit.h
    HINTS /usr/include/luajit-2.1 /usr/include/luajit-5.1 /usr/include
    PATH_SUFFIXES luajit-2.1 luajit-5.1
)

find_library(LUAJIT_LIBRARY
    NAMES luajit-5.1 luajit-2.1 luajit
    HINTS /usr/lib /usr/lib/x86_64-linux-gnu
)

if(LUAJIT_INCLUDE_DIR AND LUAJIT_LIBRARY)
    set(LUAJIT_FOUND TRUE)
    set(LUA_INCLUDE_DIR ${LUAJIT_INCLUDE_DIR})
    set(LUA_LIBRARIES ${LUAJIT_LIBRARY})
    message(STATUS "Found LuaJIT: ${LUAJIT_LIBRARY}")
else()
    set(LUAJIT_FOUND FALSE)
    message(STATUS "LuaJIT not found")
endif()
