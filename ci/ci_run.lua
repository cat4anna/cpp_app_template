#!/usr/bin/lua5.4

local lfs = require "lfs"

local function execute(t)
    local command = "\"" .. table.concat(t, "\" \"") .. "\""
    local success, reason, code = os.execute(command)
    if not success then
        os.exit(1)
    end
end

local function cleanWS(config)
    lfs.chdir(config.srcDir)
    execute({ "rm", "-rf", config.buildDir })
    lfs.mkdir(config.buildDir)
    lfs.chdir(config.buildDir)
end

local function cmakeConfigure(config)
    local cmakeCommandArgs = {
        "cmake",
        "-G", config.generator,
        "-D", "JENKINS_BUILD_NUMBER=" .. (os.getenv("BUILD_NUMBER") or "0"),
        "-D", "CMAKE_BUILD_TYPE=" .. config.name,
        "-D", string.format("VCPKG_TARGET_TRIPLET=%s", config.triplet),
        "--toolchain", os.getenv("CMAKE_TOOLCHAIN_FILE"),
        "-S", config.srcDir,
        "-B", config.buildDir,
    }
    execute(cmakeCommandArgs)
end

local function cmakeBuild(config)
    local cmakeCommandArgs = {
        "cmake",
        "--build", ".",
        "--config", config.name,
    }
    execute(cmakeCommandArgs)
end

local function cmakeInstall(config)
    local cmakeCommandArgs = {
        "cmake",
        "--install", ".",
        "--config", config.name,
    }
    execute(cmakeCommandArgs)
end

local function cmakeTest(config)
    local cmakeCommandArgs = {
        "ctest",
        ".",
        "--build-config", config.name,
        "--verbose",
    }
    execute(cmakeCommandArgs)
end

local function cmakePack(config)
    local cmakeCommandArgs = {
        "cpack",
        "-G", "ZIP",
        "-C", config.name,
    }
    execute(cmakeCommandArgs)
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
    local map = {
        debug = {
            name = "Debug",
            tripletSuffix = "",
            packageSuffix = "debug",
        },
        release = {
            name = "RelWithDebInfo",
            tripletSuffix = "-release",
            packageSuffix = "relwithdebinfo",
        }
    }
    local config = map[configName:lower()]
    config.generator = "Ninja"
    config.triplet = os.getenv("VCPKG_TARGET_TRIPLET") .. config.tripletSuffix
    config.srcDir = srcDir
    config.buildDir = string.format("%s/build/%s", srcDir, config.triplet)
    return config
end

local function main(argTable)
    for _, action in ipairs(argTable) do
        local command, configName = action:match("(%w+)-?(%w+)")
        local config = getConfig(configName)
        processAction(Commands[command], config)
    end
end

os.exit(main(arg))
