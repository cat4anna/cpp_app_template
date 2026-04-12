
if(EMSCRIPTEN)
    set(CMAKE_THREAD_LIBS_INIT "-lpthread")
    set(CMAKE_HAVE_THREADS_LIBRARY 1)
    set(CMAKE_USE_WIN32_THREADS_INIT 0)
    set(CMAKE_USE_PTHREADS_INIT 1)
    set(THREADS_PREFER_PTHREAD_FLAG ON)
endif()

if (APP_DO_BENCHMARK)
    find_package(benchmark CONFIG REQUIRED)
endif()

if (APP_DO_UNIT_TEST)
    find_package(GTest CONFIG REQUIRED)
endif()

if(PLATFORM_LINUX OR PLATFORM_WINDOWS)
    find_package(Boost CONFIG REQUIRED COMPONENTS program_options)
endif()
