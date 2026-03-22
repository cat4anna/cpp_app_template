
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
message(STATUS "target cpu: ${APP_TARGET_CPU_PLATFORM}")

if (NOT DEFINED APP_TARGET_PLATFORM)
    message(STATUS "Target system not defined, trying to detect")
    if(APP_TARGET_CPU_PLATFORM MATCHES webassembly)
        set(APP_TARGET_PLATFORM webassembly)
    elseif(CMAKE_SYSTEM MATCHES Windows)
        set(APP_TARGET_PLATFORM windows)
    elseif(CMAKE_HOST_SYSTEM MATCHES Linux)
        set(APP_TARGET_PLATFORM linux)
    else()
        message(FATAL_ERROR "Unknown target system")
    endif()
endif()

message(STATUS "Target platform: ${APP_TARGET_PLATFORM}")

if(APP_TARGET_PLATFORM MATCHES Windows)
    set(APP_INSTALL_CONFIG
        RUNTIME_DEPENDENCIES
        PRE_EXCLUDE_REGEXES "api-ms-" "ext-ms-"
        POST_EXCLUDE_REGEXES ".*system32/.*\\.dll"
    )

    add_definitions(-DPLATFORM_WINDOWS=1)
    add_definitions(-DPLATFORM_NAME=\"Windows\")

elseif(APP_TARGET_PLATFORM MATCHES Linux)
    # set(APP_INSTALL_CONFIG)

    add_definitions(-DPLATFORM_LINUX=1)
    add_definitions(-DPLATFORM_NAME=\"Linux\")
elseif(APP_TARGET_PLATFORM MATCHES Webassembly)

    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    # set_target_properties(a PROPERTIES LINK_FLAGS "-s WASM=0 -s EXPORTED_FUNCTIONS='[_main]'")

    add_definitions(-DPLATFORM_WEBASSEMBLY=1)
    add_definitions(-DPLATFORM_NAME=\"Webassembly\")
else()
    message(FATAL_ERROR "Invalid target system")
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-Wall -Wextra -Werror -pedantic)
    add_compile_options(-Wno-unused-parameter)
    add_compile_options(-Wno-missing-field-initializers)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    add_compile_options(/external:anglebrackets /external:W0 /W4 /WX /diagnostics:caret)
    add_compile_options(/wd4100) # unreferenced formal parameter
    add_compile_options(/wd4275) # non dll-interface class
endif()

add_definitions(-DPLATFORM_NAME=\"${APP_TARGET_PLATFORM}\")
add_definitions(-DBUILD_TYPE=\"${CMAKE_BUILD_TYPE}\")
add_definitions(-DVCPKG_TRIPLET=\"${VCPKG_TARGET_TRIPLET}\")
add_definitions(-DPROJECT_VERSION=\"${CMAKE_PROJECT_VERSION}\")
add_definitions(-DPROJECT_DESCRIPTION=\"${CMAKE_PROJECT_DESCRIPTION}\")
add_definitions(-DPROJECT_BUILD_NUMBER=\"${CURRENT_BUILD_NUMBER}\")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Enabling debug features")
    add_definitions(-DDEBUG)
endif()

find_program(CLANG_TIDY_EXECUTABLE NAMES clang-tidy)

if(NOT CLANG_TIDY_EXECUTABLE)
    if(APP_DO_CLANG_TIDY)
        message(FATAL_ERROR "Clang-tidy enabled but executable is not found")
    else()
        message(STATUS "Disabling clang-tidy.")
        set(CMAKE_CXX_CLANG_TIDY "")
    endif()
else()
    if(APP_DO_CLANG_TIDY)
        message(STATUS "Using clang-tidy ${CLANG_TIDY_EXECUTABLE}")
        set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY_EXECUTABLE} --header-filter=${CMAKE_CURRENT_SOURCE_DIR}/.*)
        if (APP_CLANG_TIDY_WARNINGS_AS_ERRORS)
            set(CMAKE_CXX_CLANG_TIDY ${CMAKE_CXX_CLANG_TIDY} --warnings-as-errors=*)
        endif()
    else()
        message(STATUS "Clang-tidy found, but usage was not request. Disabling.")
    endif()
endif()

function(setup_clang_tidy TARGET_NAME)
    if(APP_DO_CLANG_TIDY)
        set_target_properties(${TARGET_NAME} PROPERTIES CXX_CLANG_TIDY "${CMAKE_CXX_CLANG_TIDY}")
    endif()
endfunction()

