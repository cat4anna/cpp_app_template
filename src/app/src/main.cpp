#include <iostream>
#include "arg_parse.hpp"
#include "runner.hpp"

int main(int argc, char **argv) {
    try {
        auto args = app::runner::ParseComandline(argc, argv);
        return app::runner::ExecuteApp(*args);
    } catch (const std::exception &e) {
        std::cerr << "ERROR: " << e.what() << "\n";
    }
    return 1;
}
