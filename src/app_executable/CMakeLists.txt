define_executable(
    NAME app_executable
    PLATFORMS windows linux webassembly
    LINKS app_core Boost::program_options
)

platform_webassembly_set_executable_shell(${TARGET} "${CMAKE_CURRENT_SOURCE_DIR}/shell_minimal.html")
