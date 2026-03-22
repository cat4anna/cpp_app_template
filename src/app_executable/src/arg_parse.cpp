#include "arg_parse.hpp"
#include <boost/program_options.hpp>
#include <iostream>
#include <stdexcept>

namespace app::runner {

namespace po = boost::program_options;

struct Options {
    po::options_description all_options;
    po::options_description simulation_options{"App command line options"};
    po::positional_options_description positional_opt;

    Options() {
        // Add more here

        all_options.add_options()                                           //
            ("help", "Produce help message")                                //
            ("verbose,v", "Print diagnostic logs during compilation")       //
            ("a,value_a", po::value<int>()->default_value(1), "Value of A") //
            ("b,value_b", po::value<int>()->default_value(1), "Value of B") //
            ;
    }

    std::unique_ptr<ExecArguments> ParseComandline(int argc, char **argv) {
        try {
            po::variables_map vm;
            po::store(po::command_line_parser(argc, argv) //
                          .options(all_options)
                          .positional(positional_opt)
                          .run(),
                      vm);
            po::notify(vm);
            if (vm.count("help") > 0) {
                PrintHelp(0);
            }
            std::unique_ptr<ExecArguments> exec_args = std::make_unique<ExecArguments>();
            ReadVariableMap(vm, *exec_args);
            return exec_args;
        } catch (const std::logic_error &e) {
            std::cout << "Error when parsing command line args:\n" << e.what() << "\n\n";
            PrintHelp(1);
        }
    }

protected:
    void ReadVariableMap(const po::variables_map &vm, ExecArguments &args) {
        args.verbose = vm.count("verbose") > 0;

        args.a = vm["a"].as<int>();
        args.b = vm["b"].as<int>();

        // Add more here
    }

    [[noreturn]] void PrintHelp(int exit_code) const {
        std::cout << "App runner\n";
        std::cout << "\n";
        std::cout << all_options;
        exit(exit_code);
    }
};

std::unique_ptr<ExecArguments> ParseComandline(int argc, char **argv) {
    return Options().ParseComandline(argc, argv);
}

} // namespace app::runner
