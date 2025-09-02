cmake_minimum_required(VERSION 3.13)
project(TGFXWebDemo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif ()

# Multithreading build option
option(USE_PTHREADS "Build with pthread support" OFF)

# Collect source files
file(GLOB_RECURSE DEMO_FILES src/*.cpp)

if (DEFINED EMSCRIPTEN)
    add_executable(tgfx-web-demo ${DEMO_FILES})
    
    # Basic compile options
    list(APPEND COMPILE_OPTIONS 
        -fno-rtti 
        -DEMSCRIPTEN_HAS_UNBOUND_TYPE_NAMES=0
        -Wno-nullability-completeness
    )
    
    # Basic link options
    list(APPEND LINK_OPTIONS 
        --no-entry 
        -lembind 
        -fno-rtti 
        -DEMSCRIPTEN_HAS_UNBOUND_TYPE_NAMES=0 
        -sEXPORT_NAME='TGFXWebDemo' 
        -sWASM=1
        -sMAX_WEBGL_VERSION=2 
        -sEXPORTED_RUNTIME_METHODS=['GL','HEAPU8'] 
        -sMODULARIZE=1
        -sENVIRONMENT=web,worker 
        -sEXPORT_ES6=1
        -sALLOW_MEMORY_GROWTH=1
    )
    
    # Multithreading configuration
    if (USE_PTHREADS)
        message(STATUS "Building with pthread support")
        list(APPEND LINK_OPTIONS 
            -sUSE_PTHREADS=1 
            -sINITIAL_MEMORY=32MB 
            -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency 
            -sPROXY_TO_PTHREAD=1
            -sEXIT_RUNTIME=0 
            -sINVOKE_RUN=0
        )
        list(APPEND COMPILE_OPTIONS -fPIC -pthread)
    else ()
        message(STATUS "Building in single-threaded mode")
    endif ()
    
    # Debug/Release configuration
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        list(APPEND COMPILE_OPTIONS -O0 -g3)
        list(APPEND LINK_OPTIONS -O0 -g3 -sSAFE_HEAP=1 -sASSERTIONS=2)
    else ()
        list(APPEND COMPILE_OPTIONS -Oz)
        list(APPEND LINK_OPTIONS -Oz)
    endif ()
    
    target_compile_options(tgfx-web-demo PUBLIC ${COMPILE_OPTIONS})
    target_link_options(tgfx-web-demo PUBLIC ${LINK_OPTIONS})
    
    # Manually set TGFX library path (vcpkg approach)
    set(TGFX_LIBRARY_PATH "${CMAKE_SOURCE_DIR}/../vcpkg_installed/wasm32-emscripten/lib/tgfx.a")
    set(TGFX_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/../vcpkg_installed/wasm32-emscripten/include")
    
    # Check if library file exists
    if(NOT EXISTS ${TGFX_LIBRARY_PATH})
        message(FATAL_ERROR "TGFX library not found at: ${TGFX_LIBRARY_PATH}")
    endif()
    
    target_include_directories(tgfx-web-demo PRIVATE ${TGFX_INCLUDE_DIR})
    target_link_libraries(tgfx-web-demo ${TGFX_LIBRARY_PATH})
    
else ()
    add_library(tgfx-web-demo SHARED ${DEMO_FILES})
endif ()