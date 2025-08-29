cmake_minimum_required(VERSION 3.13)
project(demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif ()

if (APPLE)
    find_library(APPLICATION_SERVICES_FRAMEWORK ApplicationServices REQUIRED)
    list(APPEND DEMO_LIBS ${APPLICATION_SERVICES_FRAMEWORK})
    find_library(QUARTZ_CORE QuartzCore REQUIRED)
    list(APPEND DEMO_LIBS ${QUARTZ_CORE})
    find_library(COCOA Cocoa REQUIRED)
    list(APPEND DEMO_LIBS ${COCOA})
    find_library(FOUNDATION Foundation REQUIRED)
    list(APPEND DEMO_LIBS ${FOUNDATION})
    find_library(OPENGL_FRAMEWORK OpenGL REQUIRED)
    list(APPEND DEMO_LIBS ${OPENGL_FRAMEWORK})
    find_library(ICONV_LIBRARIES NAMES iconv libiconv libiconv-2 c)
    list(APPEND DEMO_LIBS ${ICONV_LIBRARIES})
    find_library(CORE_MEDIA CoreMedia)
    list(APPEND DEMO_LIBS ${CORE_MEDIA})
else ()
    find_package(Threads)
    list(APPEND DEMO_LIBS ${CMAKE_THREAD_LIBS_INIT})
    list(APPEND DEMO_LIBS dl)
    list(APPEND DEMO_COMPILE_OPTIONS -fPIC -pthread)
endif ()

# VCPKG配置
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(VCPKG_LIB_DIR ${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib)
else()
    set(VCPKG_LIB_DIR ${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib)
endif()
set(VCPKG_INCLUDE_DIR ${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include)

# 查找TGFX库
find_library(TGFX_LIBRARY NAMES tgfx.a tgfx.lib PATHS ${VCPKG_LIB_DIR} REQUIRED NO_DEFAULT_PATH)

# 创建可执行文件
add_executable(demo main.cpp)

# 设置包含目录
target_include_directories(demo PRIVATE "${VCPKG_INCLUDE_DIR}")

# 设置编译选项
if(DEMO_COMPILE_OPTIONS)
    target_compile_options(demo PRIVATE ${DEMO_COMPILE_OPTIONS})
endif()

# 链接库
target_link_libraries(demo PRIVATE "${TGFX_LIBRARY}" ${DEMO_LIBS})
