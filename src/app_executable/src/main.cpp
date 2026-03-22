#include "arg_parse.hpp"
#include "runner.hpp"
#include <iostream>

void PrintDefs() {
    std::cout
        << "PLATFORM_NAME=" << PLATFORM_NAME << "\n"
        << "BUILD_TYPE=" << BUILD_TYPE << "\n"
        << "VCPKG_TRIPLET=" << VCPKG_TRIPLET << "\n"
        << "PLATFORM_WINDOWS=" << PLATFORM_WINDOWS << "\n"
        << "PLATFORM_LINUX=" << PLATFORM_LINUX << "\n"
        << "PROJECT_VERSION=" << PROJECT_VERSION << "\n"
        << "PROJECT_BUILD_NUMBER=" << PROJECT_BUILD_NUMBER << "\n"
#ifdef DEBUG
        << "DEBUG is defined\n"
#endif
        ;
}

int main(int argc, char **argv) {
    try {
        auto args = app::runner::ParseComandline(argc, argv);
        if(args->verbose) {
            PrintDefs();
        }
        return app::runner::ExecuteApp(*args);
    } catch (const std::exception &e) {
        std::cerr << "ERROR: " << e.what() << "\n";
    }
    return 1;
}

