
find_package(Boost CONFIG REQUIRED COMPONENTS program_options)

if (APP_DO_BENCHMARK)
    find_package(benchmark CONFIG REQUIRED)
endif()

if (APP_DO_UNIT_TEST)
    find_package(GTest CONFIG REQUIRED)
endif()
