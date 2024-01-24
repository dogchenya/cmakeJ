
# 至少需要的CMake版本
cmake_minimum_required(VERSION 3.0.2 FATAL_ERROR)
# 跨平台日志输出
IF (CMAKE_SYSTEM_NAME MATCHES "Linux")
  MESSAGE(STATUS "current platform: Linux ")
ELSEIF (CMAKE_SYSTEM_NAME MATCHES "Windows")
  MESSAGE(STATUS "current platform: Windows")
ELSEIF (CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
  MESSAGE(STATUS "current platform: FreeBSD")
ELSEIF (CMAKE_SYSTEM_NAME MATCHES "Darwin")
  MESSAGE(STATUS "current platform: MacOS")
  set(OPENSSL_ROOT_DIR "/usr/local/opt/openssl" )
  set(OPENSSL_LIBRARIES "/usr/local/opt/openssl/lib" )
  set(OPENSSL_INCLUDE_DIR "/usr/local/opt/openssl/include" )
ELSE ()
  MESSAGE(STATUS "other platform: ${CMAKE_SYSTEM_NAME}")
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Linux")

if (POLICY CMP0054)
  cmake_policy(SET CMP0054 NEW)
endif()
if (POLICY CMP0057)
  cmake_policy(SET CMP0057 NEW)
endif()

# CMP0075 包含文件检查宏，遵循 CMAKE_REQUIRED_LIBRARIES
if(POLICY CMP0075)
  cmake_policy(SET CMP0075 NEW)
endif()

# 包含头文件
set(CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_SOURCE_DIR}/CMake"
  "${CMAKE_CURRENT_SOURCE_DIR}/CMake/code_builder/CMake"
  ${CMAKE_MODULE_PATH})

# 此项目信息
set(PACKAGE_NAME      "demo_cmake")
if (NOT DEFINED PACKAGE_VERSION)
  set(PACKAGE_VERSION   "0.0.1-dev")
endif()
set(PACKAGE_STRING    "${PACKAGE_NAME} ${PACKAGE_VERSION}")
set(PACKAGE_TARNAME   "${PACKAGE_NAME}-${PACKAGE_VERSION}")
set(PACKAGE_BUGREPORT "https://github.com/xxx/issues")

# 当 USE_FOLDERS 设置为 ON 时，CMake 会根据目录结构自动创建项目文件夹，
# 将相关的源文件和目标文件组织在一起。这有助于更好地组织和管理大型项目中的文件。
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
# C++ C 汇编
project(${PACKAGE_NAME} CXX C ASM)

set(INCLUDE_INSTALL_DIR include CACHE STRING
    "The subdirectory where header files should be installed")
set(LIB_INSTALL_DIR lib CACHE STRING
    "The subdirectory where libraries should be installed")
set(BIN_INSTALL_DIR bin CACHE STRING
    "The subdirectory where binaries should be installed")
set(CMAKE_INSTALL_DIR lib/cmake/demo_cmake CACHE STRING
    "The subdirectory where CMake package config files should be installed")

# 静态库
option(BUILD_SHARED_LIBS
    "If enabled, build demo as a shared library.  \
    This is generally discouraged, since demo does not commit to having \
    a stable ABI."
    OFF
  )

# Mark BUILD_SHARED_LIBS as an "advanced" option, since enabling it
# is generally discouraged.
mark_as_advanced(BUILD_SHARED_LIBS)
set(DEMO_CMAKE_SUPPORT_SHARED_LIBRARY "${BUILD_SHARED_LIBS}")

# 包含本地cmake文件
include(DemoBuildOptions)
demo_activate_static_library_option()

# C++17
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  message(STATUS "setting C++ standard to C++${CMAKE_CXX_STANDARD}")
endif()

# 跨平台选项
# todo

# 基础目录
set(TOP_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(DEMO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/demo")
set(
  DEMO_DIR_PREFIXES
  "${CMAKE_CURRENT_SOURCE_DIR}:${CMAKE_CURRENT_BINARY_DIR}"
)

include(GNUInstallDirs)

set(CMAKE_THREAD_PREFER_PTHREAD ON)
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
set(DEMO_HAVE_PTHREAD "${CMAKE_USE_PTHREADS_INIT}")
list(APPEND CMAKE_REQUIRED_LIBRARIES Threads::Threads)
list(APPEND DEMO_LINK_LIBRARIES Threads::Threads)

if(MSVC)
  include(DemoCompilerMSVC)
else()
  include(DemoCompilerUnix)
endif()
include(DemoFunctions)

include(demo-deps) # Find the required packages
# include(DemoConfigChecks)


# We currently build the main libdemo library by finding all sources
# and header files.  We then exclude specific files below.
#
# In the future it would perhaps be nicer to explicitly list the files we want
# to include, and to move the source lists in to separate per-subdirectory
# CMakeLists.txt files.
auto_sources(files "*.cpp" "RECURSE" "${DEMO_DIR}")
auto_sources(hfiles "*.h" "RECURSE" "${DEMO_DIR}")

# Exclude tests, benchmarks, and other standalone utility executables from the
# library sources.  Test sources are listed separately below.
# 排除编译目录
REMOVE_MATCHES_FROM_LISTS(files hfiles
  MATCHES
    "^${DEMO_DIR}/build/"
    "^${DEMO_DIR}/docs/examples/"
    "^${DEMO_DIR}/logging/example/"
    "^${DEMO_DIR}/(.*/)?test/"
    "^${DEMO_DIR}/(.*/)?tool/"
)

list(APPEND demo_base_files
  ${files} ${hfiles}
)

add_library(demo_base OBJECT
  ${demo_base_files}
#   ${CMAKE_CURRENT_BINARY_DIR}/demo/demo-config.h
)
if (BUILD_SHARED_LIBS)
  set_property(TARGET demo_base PROPERTY POSITION_INDEPENDENT_CODE ON)
endif()
auto_source_group(demo ${DEMO_DIR} ${files} ${hfiles})
apply_demo_compile_options_to_target(demo_base)

add_subdirectory(demo)
