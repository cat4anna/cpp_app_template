
if(POLICY CMP0167)
  cmake_policy(SET CMP0167 NEW)
endif()

find_package(Boost REQUIRED COMPONENTS program_options)
find_package(GTest CONFIG REQUIRED)
find_package(benchmark CONFIG REQUIRED)

# find_package(fmt CONFIG REQUIRED)
# find_package(PNG CONFIG REQUIRED)
# find_package(yaml-cpp CONFIG REQUIRED)
# find_package(NekoThreadPool CONFIG REQUIRED)
# find_package(slick-object-pool CONFIG REQUIRED)
# find_package(poolSTL CONFIG REQUIRED)
# find_package(thread-pool CONFIG REQUIRED)

# find_path(POOLPARTY_INCLUDE_DIRS "poolparty/pool.hpp")
# find_path(PNGPP_INCLUDE_DIRS "png++/color.hpp")

# lua provides CMake integration for the C library:
#   find_package(Lua REQUIRED)
#   target_include_directories(main PRIVATE ${LUA_INCLUDE_DIR})
#   target_link_libraries(main PRIVATE ${LUA_LIBRARIES})

# lua[cpp] provides a C++ library with exception handling:
#   find_package(unofficial-lua)
#   target_link_libraries(main PRIVATE unofficial::lua::lua-cpp)

# sol2 provides CMake targets:
#   # this is heuristically generated, and may not be correct
#   find_package(sol2 CONFIG REQUIRED)
#   target_link_libraries(main PRIVATE sol2::sol2)
# sol2 provides pkg-config modules:
#   # C++ <-> Lua Wrapper Library
#   sol2

# bgfx provides CMake targets:
#   # this is heuristically generated, and may not be correct
#   # this is heuristically generated, and may not be correct
#   find_package(bgfx CONFIG REQUIRED)
#   # note: 1 additional targets are not displayed.
#   target_link_libraries(main PRIVATE bgfx::bx bgfx::bgfx bgfx::bimg bgfx::bimg_decode)

# nanovg provides CMake targets:
#   # this is heuristically generated, and may not be correct
#   find_package(nanovg CONFIG REQUIRED)
#   target_link_libraries(main PRIVATE nanovg::nanovg)

# glfw3 provides CMake targets:
#   # this is heuristically generated, and may not be correct
#   find_package(glfw3 CONFIG REQUIRED)
#   target_link_libraries(main PRIVATE glfw)

# cairomm provides usage:
  # find_package(PkgConfig REQUIRED)
  # pkg_check_modules(CAIROMM REQUIRED IMPORTED_TARGET cairomm-1.16 cairo cairo-png)
    # target_link_libraries(main PRIVATE PkgConfig::CAIROMM)

# crossguid provides CMake targets:
#   # this is heuristically generated, and may not be correct
  # find_package(crossguid CONFIG REQUIRED)
  # target_link_libraries(main PRIVATE crossguid)


# ms-gsl provides CMake targets:
#   # this is heuristically generated, and may not be correct
#   find_package(Microsoft.GSL CONFIG REQUIRED)
#   target_link_libraries(main PRIVATE Microsoft.GSL::GSL)

# The package zlib is compatible with built-in CMake targets
    # find_package(ZLIB REQUIRED)
    # target_link_libraries(main PRIVATE ZLIB::ZLIB)