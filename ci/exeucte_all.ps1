
$docker_name = "cpp_app_template"

docker build -t $docker_nam:alpine --progress=plain -f .\ci\dockerfile.alpine .
docker build -t $docker_nam:emsdk  --progress=plain -f .\ci\dockerfile.emsdk  .

function execute-webassembly {
    param (
        [string]$action
    )

    docker run -w /workspace/source --rm `
        -v./:/workspace/source $docker_nam:emsdk `
        /usr/bin/lua5.4 ci/ci_run.lua `
        platform=webassembly `
        build-root=/tmp `
        artifacts-root=/workspace/source/build/emsdk/artifacts `
        install-root=/workspace/source/build/emsdk/install/debug `
        $action
}

function execute-alpine {
    param (
        [string]$action
    )

    docker run -w /workspace/source --rm `
        -v./:/workspace/source $docker_nam:alpine `
        /usr/bin/lua5.4 ci/ci_run.lua `
        platform=linux `
        $action
}

execute-alpine -action all-debug
execute-alpine -action all-release

execute-webassembly -action all-debug
execute-webassembly -action all-release

