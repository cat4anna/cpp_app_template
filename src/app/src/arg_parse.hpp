#pragma once

#include <memory>
#include <app_core/app_args.hpp>

namespace app::runner {

std::unique_ptr<ExecArguments> ParseComandline(int argc, char **argv);

}
