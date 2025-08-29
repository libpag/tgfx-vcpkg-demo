vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

#vcpkg_from_github(
#        OUT_SOURCE_PATH SOURCE_PATH
#        REPO Tencent/tgfx
#        REF 0b08c3a3ad48731741449ccbb18aa25e3785b75d
#        SHA512 c1ef467d5217ee01c33929bfee9db8189ebbf1916f8c5739bb485f0638341cdf5cdb7506ff3a53423f8e42abfef2b890c69ca2ca2c0bab9be5d73cc610f45937
#)

# 本地编译调试tgfx源码
set(SOURCE_PATH "/Users/huangbeiao/Documents/UGit/tgfx-vcpkg")

include("${CMAKE_CURRENT_LIST_DIR}/tgfx-functions.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/ohos-ndk-finder.cmake")

parse_and_declare_deps_externals("${SOURCE_PATH}")
get_tgfx_external_from_git("${SOURCE_PATH}")

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_SKIP_CRT_LINKAGE_CHECK enabled)
endif()
set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)

# 查找Node.js
find_program(NODEJS
        NAMES node
        PATHS
        "${CURRENT_HOST_INSTALLED_DIR}/tools/node"
        "${CURRENT_HOST_INSTALLED_DIR}/tools/node/bin"
        ENV PATH
        NO_DEFAULT_PATH
)
if(NOT NODEJS)
    message(FATAL_ERROR "node not found! Please install it via your system package manager!")
endif()

get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${NODEJS_DIR}")

# 使用vendor_tools构建（直接输出到vcpkg目录）
message(STATUS "Building TGFX using vendor_tools...")
build_tgfx_with_vendor_tools("${SOURCE_PATH}" "${NODEJS}")

# 安装头文件
file(INSTALL "${SOURCE_PATH}/include/"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp")

# 清理debug目录中的头文件和share目录
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# 创建并安装CMake配置文件
configure_file("${CMAKE_CURRENT_LIST_DIR}/tgfx-config.cmake.in"
               "${CURRENT_PACKAGES_DIR}/share/${PORT}/tgfx-config.cmake"
               @ONLY)

# 安装使用说明
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# 安装版权文件
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")