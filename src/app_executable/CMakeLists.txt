if(NOT APP_TARGET_PLATFORM MATCHES Webassembly)
    define_executable(app)
    target_link_libraries(${TARGET} PUBLIC app_core Boost::program_options)
endif()