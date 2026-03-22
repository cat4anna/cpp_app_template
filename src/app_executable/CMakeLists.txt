define_executable(
    NAME app_executable
    PLATFORMS windows linux webassembly
    LINKS app_core Boost::program_options
)