cmake_minimum_required(VERSION 3.13)
project(demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif ()

if (CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" OR CMAKE_SYSTEM_PROCESSOR STREQUAL "amd64")
    set(ARCH x64)
elseif (CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64" OR CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
    set(ARCH arm64)
else ()
    set(ARCH x86)
endif ()

# 使用find_package查找TGFX
find_package(tgfx CONFIG REQUIRED)

# 创建可执行文件
add_executable(demo main.cpp)

# 链接TGFX库（所有依赖都通过tgfx::tgfx目标自动处理）
target_link_libraries(demo PRIVATE tgfx::tgfx)