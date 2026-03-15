
if(POLICY CMP0167)
  cmake_policy(SET CMP0167 NEW)
endif()

find_package(Boost REQUIRED COMPONENTS program_options)
find_package(GTest CONFIG REQUIRED)
find_package(benchmark CONFIG REQUIRED)
