
set(TARGET_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/output/${CMAKE_BUILD_TYPE}")

if (NOT DEFINED APP_ARTIFACTS_DESTINATION)
    set(APP_ARTIFACTS_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/Artifacts")
endif()

set(TESTS_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/Testing")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${TARGET_DESTINATION})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${TARGET_DESTINATION})
set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/install")
make_directory(${APP_ARTIFACTS_DESTINATION})

message(STATUS "Target destination: ${TARGET_DESTINATION}")
message(STATUS "Artifacts destination: ${APP_ARTIFACTS_DESTINATION}")
message(STATUS "Tests destination: ${TESTS_DESTINATION}")
message(STATUS "Host system: ${CMAKE_HOST_SYSTEM}")

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-Wall -Wextra -Werror -pedantic)
    add_compile_options(-Wno-unused-parameter)
    add_compile_options(-Wno-missing-field-initializers)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    add_compile_options(/external:anglebrackets /external:W0 /W4 /WX /diagnostics:caret)
    add_compile_options(/wd4100) # unreferenced formal parameter
    add_compile_options(/wd4275) # non dll-interface class
endif()

add_definitions(-DBUILD_TYPE=\"${CMAKE_BUILD_TYPE}\")
add_definitions(-DVCPKG_TRIPLET=\"${VCPKG_TARGET_TRIPLET}\")
add_definitions(-DPROJECT_VERSION=\"${CMAKE_PROJECT_VERSION}\")
add_definitions(-DPROJECT_DESCRIPTION=\"${CMAKE_PROJECT_DESCRIPTION}\")
add_definitions(-DPROJECT_BUILD_NUMBER=\"${CURRENT_BUILD_NUMBER}\")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Enabling debug features")
    add_definitions(-DDEBUG)
else()
    add_definitions(-DRELEASE)
endif()

