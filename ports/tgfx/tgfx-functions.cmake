# Global variable to cache git path to avoid repeated detection
if(NOT DEFINED TGFX_GIT_EXECUTABLE)
    if(CMAKE_HOST_WIN32)
        find_program(TGFX_GIT_EXECUTABLE 
            NAMES git.exe git.cmd git
            PATHS ENV PATH
            DOC "Git executable path"
        )
        if(NOT TGFX_GIT_EXECUTABLE)
            execute_process(
                COMMAND where git
                OUTPUT_VARIABLE GIT_WHERE_OUTPUT
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if(GIT_WHERE_OUTPUT)
                string(REPLACE "\n" ";" GIT_PATHS "${GIT_WHERE_OUTPUT}")
                list(GET GIT_PATHS 0 TGFX_GIT_EXECUTABLE)
            endif()
        endif()
    elseif(CMAKE_HOST_APPLE)
        # macOS: use which command
        find_program(TGFX_GIT_EXECUTABLE 
            NAMES git
            PATHS /usr/bin /usr/local/bin /opt/homebrew/bin ENV PATH
            DOC "Git executable path"
        )
        if(NOT TGFX_GIT_EXECUTABLE)
            execute_process(
                COMMAND which git
                OUTPUT_VARIABLE GIT_WHICH_OUTPUT
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if(GIT_WHICH_OUTPUT)
                set(TGFX_GIT_EXECUTABLE "${GIT_WHICH_OUTPUT}")
            endif()
        endif()
    elseif (CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
        find_program(TGFX_GIT_EXECUTABLE 
            NAMES git
            PATHS /usr/bin /usr/local/bin ENV PATH
            DOC "Git executable path"
        )
        if(NOT TGFX_GIT_EXECUTABLE)
            execute_process(
                COMMAND which git
                OUTPUT_VARIABLE GIT_WHICH_OUTPUT
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if(GIT_WHICH_OUTPUT)
                set(TGFX_GIT_EXECUTABLE "${GIT_WHICH_OUTPUT}")
            endif()
        endif()
    endif()
    
    if(NOT TGFX_GIT_EXECUTABLE)
        message(FATAL_ERROR "Git executable not found, please check your environment")
    else()
        message(STATUS "Found Git executable: ${TGFX_GIT_EXECUTABLE}")
    endif()
    
    # Cache the result
    set(TGFX_GIT_EXECUTABLE "${TGFX_GIT_EXECUTABLE}" CACHE INTERNAL "Git executable path")
endif()

function(build_tgfx_single_config SOURCE_PATH NODEJS OUTPUT_DIR IS_DEBUG)
    set(BUILD_ARGS "${SOURCE_PATH}/build_tgfx")
    list(APPEND BUILD_ARGS --source "${SOURCE_PATH}")
    list(APPEND BUILD_ARGS --output "${OUTPUT_DIR}")

    if(IS_DEBUG)
        list(APPEND BUILD_ARGS --debug)
    endif()

    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND BUILD_ARGS -p win)
    elseif(VCPKG_TARGET_IS_OSX)
        list(APPEND BUILD_ARGS -p mac)
    elseif(VCPKG_TARGET_IS_IOS)
        list(APPEND BUILD_ARGS -p ios)
    elseif(VCPKG_TARGET_IS_LINUX)
        list(APPEND BUILD_ARGS -p linux)
    elseif(VCPKG_TARGET_IS_ANDROID)
        list(APPEND BUILD_ARGS -p android)
    elseif(VCPKG_CMAKE_SYSTEM_NAME MATCHES "OHOS")
        list(APPEND BUILD_ARGS -p ohos)
    elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
        list(APPEND BUILD_ARGS -p web)
    endif()

    set(ARCH "")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(ARCH "x86")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(ARCH "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(ARCH "arm")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(ARCH "arm64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "wasm32")
        # wasm: single-thread tgfx
        # wasm-mt: multi-thread tgfx
        set(ARCH "wasm-mt")
    endif()
    list(APPEND BUILD_ARGS -a ${ARCH})

    set(BUILD_TYPE_NAME "release")
    if(IS_DEBUG)
        set(BUILD_TYPE_NAME "debug")
    endif()
    
    message(STATUS "Executing: ${NODEJS} ${BUILD_ARGS}")
    message(STATUS "Using Git executable: ${TGFX_GIT_EXECUTABLE}")
    
    get_filename_component(GIT_DIR "${TGFX_GIT_EXECUTABLE}" DIRECTORY)
    set(ORIGINAL_PATH "$ENV{PATH}")
    
    if(CMAKE_HOST_WIN32)
        set(ENV{PATH} "${GIT_DIR};${ORIGINAL_PATH}")
    else()
        set(ENV{PATH} "${GIT_DIR}:${ORIGINAL_PATH}")
    endif()
    
    vcpkg_execute_required_process(
        COMMAND ${NODEJS} ${BUILD_ARGS}
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "tgfx-vendor-build-${BUILD_TYPE_NAME}"
    )
    
    set(ENV{PATH} "${ORIGINAL_PATH}")
    
    if(ARCH)
        set(ARCH_DIR "${OUTPUT_DIR}/${ARCH}")
        if(EXISTS "${ARCH_DIR}")
            file(GLOB LIB_FILES "${ARCH_DIR}/*.a" "${ARCH_DIR}/*.lib")
            foreach(LIB_FILE ${LIB_FILES})
                get_filename_component(LIB_NAME "${LIB_FILE}" NAME)
                message(STATUS "Moving ${LIB_NAME} from ${ARCH}/ to lib root")
                file(RENAME "${LIB_FILE}" "${OUTPUT_DIR}/${LIB_NAME}")
            endforeach()
            file(REMOVE_RECURSE "${ARCH_DIR}")
        endif()
    endif()
endfunction()

function(build_tgfx_with_vendor_tools SOURCE_PATH NODEJS)
    set(ENV{CMAKE_COMMAND} "${CMAKE_COMMAND}")
    set(ENV{CMAKE_PREFIX_PATH} "${CURRENT_INSTALLED_DIR}")
    message(STATUS "Building TGFX release version...")
    build_tgfx_single_config("${SOURCE_PATH}" "${NODEJS}" "${CURRENT_PACKAGES_DIR}/lib" FALSE)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        message(STATUS "Building TGFX debug version...")
        build_tgfx_single_config("${SOURCE_PATH}" "${NODEJS}" "${CURRENT_PACKAGES_DIR}/debug/lib" TRUE)
    endif()
endfunction()

