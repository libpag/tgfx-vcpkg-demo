# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5)
project(Demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_compile_options(-Wno-unused-command-line-argument)
endif ()

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

find_library(NATIVE_VSYNC_LIB native_vsync)
find_library(PIXELMAP_NDK_LIB pixelmap_ndk.z)
find_library(IMAGE_SOURCE_NDK_LIB image_source_ndk.z)
find_library(PIXELMAP_LIB pixelmap)
find_library(IMAGE_SOURCE_LIB image_source)
find_library(ACE_NDK_LIB ace_ndk.z)
find_library(HILOG_NDK_LIB hilog_ndk.z)
find_library(ACE_NAPI_LIB ace_napi.z)
find_library(NATIVE_BUFFER_LIB native_buffer)
find_library(NATIVE_WINDOW_LIB native_window)
find_library(EGL_LIB EGL)
find_library(GLES_LIB GLESv3)

file(GLOB_RECURSE DEMO_FILES *.cpp)
add_library(demo SHARED ${DEMO_FILES})

set(VCPKG_ARCH "arm64-ohos")
if (OHOS_ARCH STREQUAL "arm64-v8a")
    set(VCPKG_ARCH "arm64-ohos")
elseif(OHOS_ARCH STREQUAL "x86-64")
    set(VCPKG_ARCH "x64-ohos")
endif()

target_include_directories(demo PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../../vcpkg_installed/${VCPKG_ARCH}/include
)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(TGFX_LIB ${CMAKE_CURRENT_SOURCE_DIR}/../../../../vcpkg_installed/${VCPKG_ARCH}/debug/lib/tgfx.a)
else()
    set(TGFX_LIB ${CMAKE_CURRENT_SOURCE_DIR}/../../../../vcpkg_installed/${VCPKG_ARCH}/lib/tgfx.a)
endif()

target_link_libraries(demo
                    ${TGFX_LIB}
                    ${TGFX_SHARED_LIBS} 
                    ${NATIVE_VSYNC_LIB} 
                    ${PIXELMAP_NDK_LIB} 
                    ${IMAGE_SOURCE_NDK_LIB}
                    ${PIXELMAP_LIB}
                    ${IMAGE_SOURCE_LIB}
                    ${ACE_NDK_LIB}
                    ${HILOG_NDK_LIB}
                    ${ACE_NAPI_LIB}
                    ${NATIVE_BUFFER_LIB}
                    ${NATIVE_WINDOW_LIB}
                    ${EGL_LIB}
                    ${GLES_LIB})

