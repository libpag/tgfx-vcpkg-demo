function(parse_and_declare_deps_externals SOURCE_PATH)
    if(NOT EXISTS "${SOURCE_PATH}/DEPS")
        message(FATAL_ERROR "DEPS file not found at ${SOURCE_PATH}/DEPS")
    endif()

    file(READ "${SOURCE_PATH}/DEPS" DEPS_CONTENT)

    if(CMAKE_VERSION VERSION_LESS "3.19")
        message(FATAL_ERROR "CMake 3.19+ is required for JSON parsing")
    endif()

    string(JSON VARS_SECTION GET "${DEPS_CONTENT}" "vars")
    string(JSON PAG_GROUP GET "${VARS_SECTION}" "PAG_GROUP")

    string(JSON REPOS_SECTION GET "${DEPS_CONTENT}" "repos")
    string(JSON COMMON_REPOS GET "${REPOS_SECTION}" "common")
    string(JSON REPOS_COUNT LENGTH "${COMMON_REPOS}")

    message(STATUS "Found ${REPOS_COUNT} dependencies in DEPS file")

    set_property(GLOBAL PROPERTY TGFX_EXTERNALS "")

    math(EXPR REPOS_LAST_INDEX "${REPOS_COUNT} - 1")
    foreach(INDEX RANGE 0 ${REPOS_LAST_INDEX})
        string(JSON REPO_INFO GET "${COMMON_REPOS}" ${INDEX})
        string(JSON REPO_URL GET "${REPO_INFO}" "url")
        string(JSON REPO_COMMIT GET "${REPO_INFO}" "commit")
        string(JSON REPO_DIR GET "${REPO_INFO}" "dir")
        string(JSON VCPKG_MANAGED ERROR_VARIABLE VCPKG_ERROR GET "${REPO_INFO}" "vcpkg")

        if(VCPKG_ERROR)
            set(VCPKG_MANAGED FALSE)
        endif()

        string(REPLACE "\${PAG_GROUP}" "${PAG_GROUP}" REPO_URL "${REPO_URL}")

        get_filename_component(DEP_NAME "${REPO_DIR}" NAME)

        if(VCPKG_MANAGED)
            message(STATUS "Skipping ${DEP_NAME} - managed by vcpkg")
        else()
            message(STATUS "Declaring external dependency: ${DEP_NAME}")
            declare_tgfx_external_from_git(
                ${DEP_NAME}
                URL "${REPO_URL}"
                REF "${REPO_COMMIT}"
                DIR "${REPO_DIR}"
            )
        endif()
    endforeach()
endfunction()

function(declare_tgfx_external_from_git NAME)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "URL;REF;DIR" "")

    if(NOT arg_URL OR NOT arg_REF OR NOT arg_DIR)
        message(FATAL_ERROR "declare_tgfx_external_from_git requires URL, REF, and DIR arguments")
    endif()

    set_property(GLOBAL PROPERTY "TGFX_EXTERNAL_${NAME}_URL" "${arg_URL}")
    set_property(GLOBAL PROPERTY "TGFX_EXTERNAL_${NAME}_REF" "${arg_REF}")
    set_property(GLOBAL PROPERTY "TGFX_EXTERNAL_${NAME}_DIR" "${arg_DIR}")

    get_property(EXTERNALS GLOBAL PROPERTY TGFX_EXTERNALS)
    list(APPEND EXTERNALS "${NAME}")
    set_property(GLOBAL PROPERTY TGFX_EXTERNALS "${EXTERNALS}")
endfunction()

function(get_tgfx_external_from_git SOURCE_PATH)
    get_property(EXTERNALS GLOBAL PROPERTY TGFX_EXTERNALS)

    if(NOT EXTERNALS)
        message(STATUS "No external dependencies to fetch")
        return()
    endif()

    file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party")

    foreach(EXTERNAL ${EXTERNALS})
        get_property(URL GLOBAL PROPERTY "TGFX_EXTERNAL_${EXTERNAL}_URL")
        get_property(REF GLOBAL PROPERTY "TGFX_EXTERNAL_${EXTERNAL}_REF")
        get_property(DIR GLOBAL PROPERTY "TGFX_EXTERNAL_${EXTERNAL}_DIR")

        message(STATUS "Fetching external dependency: ${EXTERNAL} from ${URL}")

        vcpkg_from_git(
            OUT_SOURCE_PATH DEP_SOURCE_PATH
            URL "${URL}"
            REF "${REF}"
        )

        get_filename_component(TARGET_DIR "${SOURCE_PATH}/${DIR}" DIRECTORY)
        file(MAKE_DIRECTORY "${TARGET_DIR}")

        message(STATUS "Copying ${EXTERNAL} to ${SOURCE_PATH}/${DIR}")
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/${DIR}")
    endforeach()

    message(STATUS "Successfully fetched all external dependencies")
endfunction()

function(build_tgfx_single_config SOURCE_PATH NODEJS OUTPUT_DIR IS_DEBUG)
    # 构建参数
    set(BUILD_ARGS "${SOURCE_PATH}/build_tgfx")
    list(APPEND BUILD_ARGS --source "${SOURCE_PATH}")
    list(APPEND BUILD_ARGS --output "${OUTPUT_DIR}")
    
    # 添加debug参数
    if(IS_DEBUG)
        list(APPEND BUILD_ARGS --debug)
    endif()

    # 添加平台参数
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
    endif()

    # 添加架构参数
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        list(APPEND BUILD_ARGS -a x86)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        list(APPEND BUILD_ARGS -a x64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        list(APPEND BUILD_ARGS -a arm)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        list(APPEND BUILD_ARGS -a arm64)
    endif()

    # 执行构建
    set(BUILD_TYPE_NAME "release")
    if(IS_DEBUG)
        set(BUILD_TYPE_NAME "debug")
    endif()
    
    message(STATUS "Executing: ${NODEJS} ${BUILD_ARGS}")
    vcpkg_execute_required_process(
        COMMAND ${NODEJS} ${BUILD_ARGS}
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "tgfx-vendor-build-${BUILD_TYPE_NAME}"
    )
    
    if(VCPKG_TARGET_ARCHITECTURE)
        set(ARCH_DIR "${OUTPUT_DIR}/${VCPKG_TARGET_ARCHITECTURE}")
        if(EXISTS "${ARCH_DIR}")
            file(GLOB LIB_FILES "${ARCH_DIR}/*.a" "${ARCH_DIR}/*.lib")
            foreach(LIB_FILE ${LIB_FILES})
                get_filename_component(LIB_NAME "${LIB_FILE}" NAME)
                message(STATUS "Moving ${LIB_NAME} from ${VCPKG_TARGET_ARCHITECTURE}/ to lib root")
                file(RENAME "${LIB_FILE}" "${OUTPUT_DIR}/${LIB_NAME}")
            endforeach()
            
            # 删除空的架构文件夹
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

