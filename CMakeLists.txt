cmake_minimum_required(VERSION 3.13)
project(demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif ()

find_package(tgfx CONFIG REQUIRED)
add_executable(demo main.cpp)
target_link_libraries(demo PRIVATE tgfx::tgfx)