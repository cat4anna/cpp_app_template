#include <iostream>
#include <format>

#include <app_core/sum.hpp>
#include "runner.hpp"

namespace app::runner {

struct AppRunner {
    const ExecArguments &appArgs;

    explicit AppRunner(const ExecArguments &args): appArgs(args) {}

    int Run() {
        if(appArgs.verbose) {
            std::cout << "Starting App...\n";
        }

        int result = app::sum(appArgs.a, appArgs.b);

        if(appArgs.verbose) {
            std::cout << std::format("{}+{}={}\n", appArgs.a, appArgs.b, result);
        } else {
            std::cout << std::format("{}\n", result);
        }

        if(appArgs.verbose) {
            std::cout << "App finished\n";
        }
        return 0;
    }
};

int ExecuteApp(const ExecArguments &args) {
    return std::make_unique<AppRunner>(args)->Run();
}

}
