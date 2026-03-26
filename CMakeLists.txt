cmake_minimum_required(VERSION 3.28)

project(cpp_app_template)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include("add_all_subdirectories")
include("configuration")
include("setup_compiler")
include("setup_platform")
include("setup_packages")
include("setup_packaging")
include("setup_clang_tidy")
include("targets_sub")
include("targets_default")

add_subdirectory(src)
add_subdirectory(test)
