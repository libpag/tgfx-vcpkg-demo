cmake_minimum_required(VERSION 3.10)
project(demo)

set(CMAKE_CXX_STANDARD 17)

add_executable(demo main.cpp)

find_package(tgfx CONFIG REQUIRED)

target_link_libraries(demo PRIVATE tgfx::tgfx)
