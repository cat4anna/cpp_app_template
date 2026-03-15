
set(TARGET_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/output/${CMAKE_BUILD_TYPE}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${TARGET_DESTINATION})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${TARGET_DESTINATION})
set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/install")
message(STATUS "Target destination: " ${TARGET_DESTINATION})

if(CMAKE_SYSTEM MATCHES Windows)
    set(APP_INSTALL_CONFIG
        RUNTIME_DEPENDENCIES
        PRE_EXCLUDE_REGEXES "api-ms-" "ext-ms-"
        POST_EXCLUDE_REGEXES ".*system32/.*\\.dll"
    )

    add_definitions(-DPLATFORM_WINDOWS=1)
    add_definitions(-DPLATFORM_LINUX=0)
    add_definitions(-DPLATFORM_NAME=\"Windows\")

else(CMAKE_HOST_SYSTEM MATCHES Linux)
    # set(APP_INSTALL_CONFIG)

    add_definitions(-DPLATFORM_WINDOWS=0)
    add_definitions(-DPLATFORM_LINUX=1)
    add_definitions(-DPLATFORM_NAME=\"Linux\")
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

add_definitions(-DBUILD_TYPE=\"${CMAKE_BUILD_TYPE}\")
add_definitions(-DVCPKG_TRIPLET=\"${VCPKG_TARGET_TRIPLET}\")
add_definitions(-DPROJECT_VERSION=\"${CMAKE_PROJECT_VERSION}\")
add_definitions(-DPROJECT_DESCRIPTION=\"${CMAKE_PROJECT_DESCRIPTION}\")
add_definitions(-DPROJECT_BUILD_NUMBER=\"${CURRENT_BUILD_NUMBER}\")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Enabling debug features")
    add_definitions(-DDEBUG)
endif()

find_program(clang_tidy_executable NAMES clang-tidy)

if(NOT clang_tidy_executable)
    if(APP_DO_CLANG_TIDY)
        message(FATAL_ERROR "Clang-tidy enabled but executable is not found")
    else()
        message(STATUS "Disabling clang-tidy.")
        set(CMAKE_CXX_CLANG_TIDY "")
    endif()
else()
    if(APP_DO_CLANG_TIDY)
        message(STATUS "Using clang-tidy ${clang_tidy_executable}")
        set(CMAKE_CXX_CLANG_TIDY ${clang_tidy_executable} --header-filter=${CMAKE_CURRENT_SOURCE_DIR}/.*)
        if (APP_CLANG_TIDY_WARNINGS_AS_ERRORS)
            set(CMAKE_CXX_CLANG_TIDY ${CMAKE_CXX_CLANG_TIDY} --warnings-as-errors=*)
        endif()
    elseif()
        message(STATUS "Clang-tidy found, but usage was not request. Disabling.")
    endif()
endif()

function(setup_clang_tidy TARGET_NAME)
    if(APP_DO_CLANG_TIDY)
        set_target_properties(${TARGET_NAME} PROPERTIES CXX_CLANG_TIDY "${CMAKE_CXX_CLANG_TIDY}")
    endif()
endfunction()

