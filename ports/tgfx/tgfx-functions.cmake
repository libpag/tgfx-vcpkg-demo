if(VCPKG_TARGET_IS_WINDOWS)
    set(ORIGINAL_PATH "$ENV{PATH}")
    
    execute_process(
        COMMAND powershell -Command "[Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH', 'User')"
        OUTPUT_VARIABLE FULL_SYSTEM_PATH
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
        
    if(NOT FULL_SYSTEM_PATH)
        message(FATAL_ERROR "Failed to retrieve system PATH using PowerShell. Git detection cannot proceed.")
    endif()
        
    set(COMBINED_PATH "${ORIGINAL_PATH};${FULL_SYSTEM_PATH}")
    set(ENV{PATH} "${COMBINED_PATH}")
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
    
    vcpkg_execute_required_process(
        COMMAND ${NODEJS} ${BUILD_ARGS}
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "tgfx-vendor-build-${BUILD_TYPE_NAME}"
    )
    
    if(ARCH)
        set(ARCH_DIR "${OUTPUT_DIR}/${ARCH}")
        if(EXISTS "${ARCH_DIR}")
            file(GLOB LIB_FILES "${ARCH_DIR}/*.a" "${ARCH_DIR}/*.lib")
            foreach(LIB_FILE ${LIB_FILES})
                get_filename_component(LIB_NAME "${LIB_FILE}" NAME)
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