
if (NOT DEFINED APP_TARGET_PLATFORM)
    message(STATUS "Target system not defined, trying to detect")
    if(APP_TARGET_PLATFORM MATCHES webassembly)
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

if(APP_TARGET_PLATFORM MATCHES windows)
    set(PLATFORM_WINDOWS TRUE)

    set(APP_INSTALL_CONFIG
        RUNTIME_DEPENDENCIES
        PRE_EXCLUDE_REGEXES "api-ms-" "ext-ms-"
        POST_EXCLUDE_REGEXES ".*system32/.*\\.dll"
    )

    add_definitions(-DPLATFORM_WINDOWS=1)
    add_definitions(-DPLATFORM_NAME=\"Windows\")

elseif(APP_TARGET_PLATFORM MATCHES linux)
    set(PLATFORM_LINUX TRUE)

    add_definitions(-DPLATFORM_LINUX=1)
    add_definitions(-DPLATFORM_NAME=\"Linux\")
elseif(APP_TARGET_PLATFORM MATCHES webassembly)
    set(PLATFORM_WEBASSEMBLY TRUE)

    add_definitions(-DPLATFORM_WEBASSEMBLY=1)
    add_definitions(-DPLATFORM_NAME=\"Webassembly\")

    set(EMSCRIPTEN TRUE)
    set(CMAKE_TEST_LAUNCHER node)
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
else()
    message(FATAL_ERROR "Invalid target system")
endif()

function(platform_webassembly_set_executable_shell TARGET SHELL_FILE)
    if(EMSCRIPTEN)
        target_link_options(${TARGET} PRIVATE "--shell-file" "${SHELL_FILE}")
        target_sources(${TARGET} PRIVATE ${SHELL_FILE})
    endif()
endfunction()
