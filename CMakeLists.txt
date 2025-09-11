cmake_minimum_required(VERSION 3.13)
project(demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif ()

if (WIN32)
    if (MSVC)
        add_compile_options("/utf-8")
        string(TOLOWER ${MSVC_C_ARCHITECTURE_ID} ARCH)
        
        # Force consistent runtime library usage
        if (CMAKE_BUILD_TYPE MATCHES "Debug")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDebugDLL")
            add_compile_definitions(_ITERATOR_DEBUG_LEVEL=2)
        else()
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
            add_compile_definitions(_ITERATOR_DEBUG_LEVEL=0)
        endif()
    endif (MSVC)

    # Windows definitions from official tgfx
    add_definitions(-DNOMINMAX -D_USE_MATH_DEFINES -DWIN32 -D_WINDOWS -D_CRT_SECURE_NO_WARNINGS)
    
    # Windows version detection and library linking
    if (${CMAKE_SYSTEM_VERSION} VERSION_GREATER_EQUAL 6.3) # Windows 8.1 or later
        add_definitions(-D_WIN32_WINNT=0x0603)
        find_library(SHCORE_LIB SHCore)
        list(APPEND DEMO_LIBS ${SHCORE_LIB})
    else ()
        add_definitions(-D_WIN32_WINNT=0x0601) # Windows 7
        find_library(USER32 user32)
        list(APPEND DEMO_LIBS ${USER32})
    endif ()

    # Debug/Release definitions
    if (CMAKE_BUILD_TYPE MATCHES "Debug")
        add_definitions(-DDEBUG)
    else ()
        add_definitions(-DNDEBUG)
    endif ()
    
    # Link required Windows system libraries for MSVC runtime
    link_libraries(
        kernel32
        user32
        gdi32
        winspool
        shell32
        ole32
        oleaut32
        uuid
        comdlg32
        advapi32
        synchronization
    )
endif()

find_package(tgfx CONFIG REQUIRED)
add_executable(demo main.cpp)
target_link_libraries(demo PRIVATE tgfx::tgfx)
if(DEMO_LIBS)
    target_link_libraries(demo PRIVATE ${DEMO_LIBS})
endif()