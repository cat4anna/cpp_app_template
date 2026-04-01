#!/usr/bin/lua5.4

local lfs = require "lfs"

local dry_run = false

local function execute(t)
    local command = "\"" .. table.concat(t, "\" \"") .. "\""
    print("Triggering: " .. command)
    if not dry_run then
        local success, reason, code = os.execute(command)
        if not success then
            os.exit(1)
        end
    end
end

local function cleanWS(config)
    lfs.chdir(config.srcDir)
    execute({ "rm", "-rf", config.buildDir })
    lfs.mkdir(config.buildDir)
end

local function addArgsToCmake(command, config, add_def, stage)
    for k, v in pairs(config.args) do
        if v.cmake and (v.value ~= nil) then
            if add_def and v.cmake.definition then
                table.insert(command, string.format("-D%s=%s", v.cmake.definition, v.value))
            end
            if v.cmake[stage] then
                table.insert(command, string.format("%s=%s", v.cmake[stage], v.value))
            end
        end
    end
end

local function executeCmakeCommand(command, config, stage, add_def)
    local execPrefixArg = config.args["execute-prefix-" .. stage]
    if execPrefixArg and execPrefixArg.value then
        table.insert(command, 1, execPrefixArg.value)
    end
    addArgsToCmake(command, config, add_def, stage)
    execute(command)
end

local function cmakeConfigure(config)
    lfs.chdir(config.srcDir)
    local command = {
        "cmake",
        string.format("-DJENKINS_BUILD_NUMBER=%s", os.getenv("APP_BUILD_NUMBER") or os.getenv("BUILD_NUMBER") or "0"),
        string.format("-DCMAKE_BUILD_TYPE=%s", config.name),
        string.format("-DVCPKG_TARGET_TRIPLET=%s", config.triplet),
        string.format("-DPACKAGE_NAME_SUFFIX=%s", config.packageSuffix),
        string.format("-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=%s", os.getenv("VCPKG_CHAINLOAD_TOOLCHAIN_FILE") or ""),
        string.format("-DCMAKE_TOOLCHAIN_FILE=%s", os.getenv("VCPKG_CMAKE_TOOLCHAIN_FILE") or ""),
        string.format("--toolchain=%s", os.getenv("VCPKG_CMAKE_TOOLCHAIN_FILE")),
        "-S", config.srcDir,
        "-B", config.buildDir,
    }
    executeCmakeCommand(command, config, "configure", true)
end

local function cmakeBuild(config)
    local command = {
        "cmake",
        "--build", ".",
        "--config", config.name,
    }
    executeCmakeCommand(command, config, "build")
end

local function cmakeInstall(config)
    local toInstall = {
        "main",
    }
    if (config.args["unit-test"].value ~= "OFF" or config.args["benchmark"].value ~= "OFF") then
        table.insert(toInstall, "test")
    end

    for _, v in ipairs(toInstall) do
        local command = {
            "cmake",
            "--install", ".",
            "--config", config.name,
            "--component=" .. v
        }
        executeCmakeCommand(command, config, "install")
    end
end

local function cmakeTest(config)
    if not (config.args["unit-test"].value ~= "OFF" and config.args["benchmark"].value ~= "OFF") then
        print("Skipping tests")
        return
    end
    local command = {
        "ctest",
        ".",
        "--build-config", config.name,
    }
    executeCmakeCommand(command, config, "test")
end

local function cmakePack(config)
    local command = {
        "cpack",
        "-G", "ZIP",
        "-C", config.name,
        "-D", string.format("PACKAGE_NAME_SUFFIX=%s", config.packageSuffix),
    }
    executeCmakeCommand(command, config, "pack")
end

Commands = {
    all = {
        "clean",
        "configure",
        "build",
        "install",
        "test",
        "pack",
    },

    clean = cleanWS,
    configure = cmakeConfigure,
    build = cmakeBuild,
    install = cmakeInstall,
    test = cmakeTest,
    pack = cmakePack,
}

local ArgsMap = {
    platform = {
        value = "linux",
        allowed = { linux = 1, windows = 1, webassembly = 1 },
        cmake = { definition = "APP_TARGET_PLATFORM" },
        apply_values = {
            webassembly = {
                ["clang-tidy"] = "OFF",
                ["execute-prefix-configure"] = "emcmake",
            }
        }
    },
    ["build-root"] = {
        value = lfs.currentdir(),
    },
    ["install-root"] = {
        cmake = { install = "--prefix" },
    },
    ["package-root"] = {
        cmake = { pack = "-B" },
    },
    ["artifacts-root"] = {
        cmake = { definition = "APP_ARTIFACTS_DESTINATION" },
    },
    generator = {
        value = "Ninja",
        cmake = { configure = "-G" },
    },
    ["clang-tidy"] = {
        cmake = { definition = "APP_DO_CLANG_TIDY" },
    },
    ["unit-test"] = {
        cmake = { definition = "APP_DO_UNIT_TEST" },
    },
    ["benchmark"] = {
        cmake = { definition = "APP_DO_BENCHMARK" },
    },
    ["execute-prefix-configure"] = {},
    ["execute-prefix-build"] = {},
    ["execute-prefix-install"] = {},
    ["execute-prefix-test"] = {},
    ["execute-prefix-pack"] = {},
}

local WindowsLinuxPlatform = {
    debug = {
        name = "Debug",
        tripletSuffix = "",
        packageSuffix = "-debug",
        buildDirSuffix = "-debug",
    },
    release = {
        name = "RelWithDebInfo",
        tripletSuffix = "-release",
        packageSuffix = "",
        buildDirSuffix = "-release",
    }
}

local ConfigurationMap = {
    windows = WindowsLinuxPlatform,
    linux = WindowsLinuxPlatform,
    webassembly = {
        debug = {
            name = "Debug",
            tripletSuffix = "",
            packageSuffix = "-debug",
            buildDirSuffix = "-debug",
        },
        release = {
            name = "RelWithDebInfo",
            tripletSuffix = "",
            packageSuffix = "-release",
            buildDirSuffix = "-release",
        }
    }
}

local function processAction(handler, config)
    if (type(handler) == "table") then
        for _, what in ipairs(handler) do
            processAction(Commands[what], config)
        end
    else
        lfs.mkdir(config.buildDir)
        lfs.chdir(config.buildDir)
        handler(config)
    end
end

local function getConfig(configName)
    local srcDir = lfs.currentdir()
    local config = ConfigurationMap[ArgsMap.platform.value][configName:lower()]
    config.args = ArgsMap
    config.triplet = os.getenv("VCPKG_TARGET_TRIPLET") .. config.tripletSuffix
    config.srcDir = srcDir
    config.buildDir = string.format("%s/build/%s%s", ArgsMap["build-root"].value, os.getenv("VCPKG_TARGET_TRIPLET"),
        config.buildDirSuffix)
    return config
end

local function setArg(argName, value)
    if not ArgsMap[argName] then
        print(string.format("ERROR: argument %s is not valid", argName))
        os.exit(1)
    end
    local argConfig = ArgsMap[argName]
    if argConfig.allowed and (not argConfig.allowed[value]) then
        print(string.format("ERROR: Value %s is not valid for %s", value, argName))
        os.exit(1)
    end

    print(string.format("Setting %s=%s", argName, value))
    argConfig.value = value
    if argConfig.apply_values then
        local av = argConfig.apply_values[value]
        if av then
            for k, v in pairs(av) do
                setArg(k, v)
            end
        end
    end
end

local function main(argTable)
    for _, action in ipairs(argTable) do
        if action == "dry-run" then
            print("Entering dry-run mode")
            dry_run = true
        elseif action:match("=") then
            local first, second = action:match("([^=]+)=([^=]+)")
            setArg(first, second)
        else
            local first, second = action:match("(%w+)-?(%w*)")
            if second == "" then
                second = nil
            end
            local config = getConfig(second or "release")
            processAction(Commands[first], config)
        end
    end
end

os.exit(main(arg))
