# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include(CheckCXXSourceCompiles)
include(CheckCXXSymbolExists)
include(CheckIncludeFileCXX)
include(CheckFunctionExists)
include(CMakePushCheckState)

set(
  BOOST_LINK_STATIC "auto"
  CACHE STRING
  "Whether to link against boost statically or dynamically."
)
if("${BOOST_LINK_STATIC}" STREQUAL "auto")
  # Default to linking boost statically on Windows with MSVC
  if(MSVC)
    set(DEMO_BOOST_LINK_STATIC ON)
  else()
    set(DEMO_BOOST_LINK_STATIC OFF)
  endif()
else()
  set(DEMO_BOOST_LINK_STATIC "${BOOST_LINK_STATIC}")
endif()
set(Boost_USE_STATIC_LIBS "${DEMO_BOOST_LINK_STATIC}")

# 链接boost库
find_package(Boost 1.51.0 MODULE
  COMPONENTS
    context
    filesystem
    program_options
    regex
    system
    thread
  REQUIRED
)
list(APPEND DEMO_LINK_LIBRARIES ${Boost_LIBRARIES})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${Boost_INCLUDE_DIRS})

# DoubleConversion 是一个开源的 C++ 库，用于进行数字转换和格式化。
# 它提供了高性能和精确的数字转换功能，包括将数字从字符串转换为二进制表示（如 double 或 int64），以及将二进制表示转换回字符串。
# DoubleConversion 库最初由 Google 开发，用于 V8 JavaScript 引擎中的数字转换和格式化操作。它被设计为快速且准确，适用于高性能的数值处理应用。
find_package(DoubleConversion MODULE REQUIRED)
list(APPEND DEMO_LINK_LIBRARIES ${DOUBLE_CONVERSION_LIBRARY})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${DOUBLE_CONVERSION_INCLUDE_DIR})

# Gflags（也称为 Google Flags）是一个开源的命令行参数解析库，由 Google 开发。它提供了一种方便的方式来定义、解析和访问命令行参数。
find_package(Gflags MODULE)
set(DEMO_HAVE_LIBGFLAGS ${LIBGFLAGS_FOUND})
if(LIBGFLAGS_FOUND)
  list(APPEND DEMO_LINK_LIBRARIES ${LIBGFLAGS_LIBRARY})
  list(APPEND DEMO_INCLUDE_DIRECTORIES ${LIBGFLAGS_INCLUDE_DIR})
  set(DEMO_LIBGFLAGS_LIBRARY ${LIBGFLAGS_LIBRARY})
  set(DEMO_LIBGFLAGS_INCLUDE ${LIBGFLAGS_INCLUDE_DIR})
endif()

# 链接日志库
find_package(Glog MODULE)
set(DEMO_HAVE_LIBGLOG ${GLOG_FOUND})
list(APPEND DEMO_LINK_LIBRARIES ${GLOG_LIBRARY})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${GLOG_INCLUDE_DIR})

# LibEvent 是一个开源的事件通知库，用于在网络编程中处理事件驱动的程序。
# 它提供了跨平台的抽象接口，使开发人员可以编写高性能、可扩展的网络应用程序。
find_package(LibEvent MODULE REQUIRED)
list(APPEND DEMO_LINK_LIBRARIES ${LIBEVENT_LIB})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${LIBEVENT_INCLUDE_DIR})

# ZLIB 是一个开源的数据压缩库，用于对数据进行无损压缩和解压缩。
find_package(ZLIB MODULE)
set(DEMO_HAVE_LIBZ ${ZLIB_FOUND})
if (ZLIB_FOUND)
  list(APPEND DEMO_INCLUDE_DIRECTORIES ${ZLIB_INCLUDE_DIRS})
  list(APPEND DEMO_LINK_LIBRARIES ${ZLIB_LIBRARIES})
  list(APPEND CMAKE_REQUIRED_LIBRARIES ${ZLIB_LIBRARIES})
endif()

# OpenSSL 是一个开源的密码学库
find_package(OpenSSL 1.1.1 MODULE REQUIRED)
list(APPEND DEMO_LINK_LIBRARIES ${OPENSSL_LIBRARIES})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR})
list(APPEND CMAKE_REQUIRED_LIBRARIES ${OPENSSL_LIBRARIES})
list(APPEND CMAKE_REQUIRED_INCLUDES ${OPENSSL_INCLUDE_DIR})
check_function_exists(ASN1_TIME_diff DEMO_HAVE_OPENSSL_ASN1_TIME_DIFF)
list(REMOVE_ITEM CMAKE_REQUIRED_LIBRARIES ${OPENSSL_LIBRARIES})
list(REMOVE_ITEM CMAKE_REQUIRED_INCLUDES ${OPENSSL_INCLUDE_DIR})
if (ZLIB_FOUND)
    list(REMOVE_ITEM CMAKE_REQUIRED_LIBRARIES ${ZLIB_LIBRARIES})
endif()

# BZip2 是一个开源的数据压缩库，用于对数据进行无损压缩和解压缩。
find_package(BZip2 MODULE)
set(DEMO_HAVE_LIBBZ2 ${BZIP2_FOUND})
if (BZIP2_FOUND)
  list(APPEND DEMO_INCLUDE_DIRECTORIES ${BZIP2_INCLUDE_DIRS})
  list(APPEND DEMO_LINK_LIBRARIES ${BZIP2_LIBRARIES})
endif()

find_package(LibLZMA MODULE)
set(DEMO_HAVE_LIBLZMA ${LIBLZMA_FOUND})
if (LIBLZMA_FOUND)
  list(APPEND DEMO_INCLUDE_DIRECTORIES ${LIBLZMA_INCLUDE_DIRS})
  list(APPEND DEMO_LINK_LIBRARIES ${LIBLZMA_LIBRARIES})
endif()

find_package(LZ4 MODULE)
set(DEMO_HAVE_LIBLZ4 ${LZ4_FOUND})
if (LZ4_FOUND)
  list(APPEND DEMO_INCLUDE_DIRECTORIES ${LZ4_INCLUDE_DIR})
  list(APPEND DEMO_LINK_LIBRARIES ${LZ4_LIBRARY})
endif()

find_package(Zstd MODULE)
set(DEMO_HAVE_LIBZSTD ${ZSTD_FOUND})
if(ZSTD_FOUND)
  list(APPEND DEMO_INCLUDE_DIRECTORIES ${ZSTD_INCLUDE_DIR})
  list(APPEND DEMO_LINK_LIBRARIES ${ZSTD_LIBRARY})
endif()

# Snappy 是一个开源的数据压缩库
find_package(Snappy MODULE)
set(DEMO_HAVE_LIBSNAPPY ${SNAPPY_FOUND})
if (SNAPPY_FOUND)
  list(APPEND DEMO_INCLUDE_DIRECTORIES ${SNAPPY_INCLUDE_DIR})
  list(APPEND DEMO_LINK_LIBRARIES ${SNAPPY_LIBRARY})
endif()

find_package(LibDwarf)
list(APPEND DEMO_LINK_LIBRARIES ${LIBDWARF_LIBRARIES})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${LIBDWARF_INCLUDE_DIRS})

find_package(Libiberty)
list(APPEND DEMO_LINK_LIBRARIES ${LIBIBERTY_LIBRARIES})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${LIBIBERTY_INCLUDE_DIRS})

# LibAIO（Asynchronous I/O Library）是一个用于实现异步 I/O 操作的库。
# 它提供了一组函数和接口，使应用程序能够以非阻塞的方式进行文件 I/O 操作。
find_package(LibAIO)
list(APPEND DEMO_LINK_LIBRARIES ${LIBAIO_LIBRARIES})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${LIBAIO_INCLUDE_DIRS})

find_package(LibUring)
list(APPEND DEMO_LINK_LIBRARIES ${LIBURING_LIBRARIES})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${LIBURING_INCLUDE_DIRS})

find_package(Libsodium)
list(APPEND DEMO_LINK_LIBRARIES ${LIBSODIUM_LIBRARIES})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${LIBSODIUM_INCLUDE_DIRS})

list(APPEND DEMO_LINK_LIBRARIES ${CMAKE_DL_LIBS})
list(APPEND CMAKE_REQUIRED_LIBRARIES ${CMAKE_DL_LIBS})

if (PYTHON_EXTENSIONS)
  find_package(PythonInterp 3.6 REQUIRED)
  find_package(Cython 0.26 REQUIRED)
endif ()

# LibUnwind 是一个用于获取和操作程序运行时调用栈信息的库。
# 它提供了一组函数和接口，可以在程序运行时动态地获取当前线程的调用栈信息，包括函数调用关系、函数名、源代码位置等。
find_package(LibUnwind)
list(APPEND DEMO_LINK_LIBRARIES ${LIBUNWIND_LIBRARIES})
list(APPEND DEMO_INCLUDE_DIRECTORIES ${LIBUNWIND_INCLUDE_DIRS})
if (LIBUNWIND_FOUND)
  set(DEMO_HAVE_LIBUNWIND ON)
endif()
if (CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
  list(APPEND DEMO_LINK_LIBRARIES "execinfo")
endif ()

cmake_push_check_state()
set(CMAKE_REQUIRED_DEFINITIONS -D_XOPEN_SOURCE)
check_cxx_symbol_exists(swapcontext ucontext.h DEMO_HAVE_SWAPCONTEXT)
cmake_pop_check_state()

set(DEMO_USE_SYMBOLIZER OFF)
CHECK_INCLUDE_FILE_CXX(elf.h DEMO_HAVE_ELF)
find_package(Backtrace)

set(DEMO_HAVE_BACKTRACE ${Backtrace_FOUND})
set(DEMO_HAVE_DWARF ${LIBDWARF_FOUND})
if (NOT WIN32 AND NOT APPLE)
  set(DEMO_USE_SYMBOLIZER ON)
endif()
message(STATUS "Setting DEMO_USE_SYMBOLIZER: ${DEMO_USE_SYMBOLIZER}")
message(STATUS "Setting DEMO_HAVE_ELF: ${DEMO_HAVE_ELF}")
message(STATUS "Setting DEMO_HAVE_DWARF: ${DEMO_HAVE_DWARF}")

# Using clang with libstdc++ requires explicitly linking against libatomic
check_cxx_source_compiles("
  #include <atomic>
  int main(int argc, char** argv) {
    struct Test { bool val; };
    std::atomic<Test> s;
    return static_cast<int>(s.is_lock_free());
  }"
  DEMO_CPP_ATOMIC_BUILTIN
)
if(NOT DEMO_CPP_ATOMIC_BUILTIN)
  list(APPEND CMAKE_REQUIRED_LIBRARIES atomic)
  list(APPEND DEMO_LINK_LIBRARIES atomic)
  check_cxx_source_compiles("
    #include <atomic>
    int main(int argc, char** argv) {
      struct Test { bool val; };
      std::atomic<Test> s2;
      return static_cast<int>(s2.is_lock_free());
    }"
    DEMO_CPP_ATOMIC_WITH_LIBATOMIC
  )
  if (NOT DEMO_CPP_ATOMIC_WITH_LIBATOMIC)
    message(
      FATAL_ERROR "unable to link C++ std::atomic code: you may need \
      to install GNU libatomic"
    )
  endif()
endif()

check_cxx_source_compiles("
  #include <type_traits>
  #if _GLIBCXX_RELEASE
  int main() {}
  #endif"
  DEMO_STDLIB_LIBSTDCXX
)
check_cxx_source_compiles("
  #include <type_traits>
  #if _GLIBCXX_RELEASE >= 9
  int main() {}
  #endif"
  DEMO_STDLIB_LIBSTDCXX_GE_9
)
check_cxx_source_compiles("
  #include <type_traits>
  #if _LIBCPP_VERSION
  int main() {}
  #endif"
  DEMO_STDLIB_LIBCXX
)
check_cxx_source_compiles("
  #include <type_traits>
  #if _LIBCPP_VERSION >= 9000
  int main() {}
  #endif"
  DEMO_STDLIB_LIBCXX_GE_9
)
check_cxx_source_compiles("
  #include <type_traits>
  #if _CPPLIB_VER
  int main() {}
  #endif"
  DEMO_STDLIB_LIBCPP
)

if (APPLE)
  list (APPEND CMAKE_REQUIRED_LIBRARIES c++abi)
  list (APPEND DEMO_LINK_LIBRARIES c++abi)
endif ()

if (DEMO_STDLIB_LIBSTDCXX AND NOT DEMO_STDLIB_LIBSTDCXX_GE_9)
  list (APPEND CMAKE_REQUIRED_LIBRARIES stdc++fs)
  list (APPEND DEMO_LINK_LIBRARIES stdc++fs)
endif()
if (DEMO_STDLIB_LIBCXX AND NOT DEMO_STDLIB_LIBCXX_GE_9)
  list (APPEND CMAKE_REQUIRED_LIBRARIES c++fs)
  list (APPEND DEMO_LINK_LIBRARIES c++fs)
endif ()

option(
  DEMO_LIBRARY_SANITIZE_ADDRESS
  "Build demo with Address Sanitizer enabled."
  OFF
)

if ($ENV{WITH_ASAN})
  message(STATUS "ENV WITH_ASAN is set")
  set (DEMO_LIBRARY_SANITIZE_ADDRESS ON)
endif()

if (DEMO_LIBRARY_SANITIZE_ADDRESS)
  if ("${CMAKE_CXX_COMPILER_ID}" MATCHES GNU)
    set(DEMO_LIBRARY_SANITIZE_ADDRESS ON)
    set(DEMO_ASAN_FLAGS -fsanitize=address,undefined)
    list(APPEND DEMO_CXX_FLAGS ${DEMO_ASAN_FLAGS})
    # All of the functions in demo/detail/Sse.cpp are intended to be compiled
    # with ASAN disabled.  They are marked with attributes to disable the
    # sanitizer, but even so, gcc fails to compile them for some reason when
    # sanitization is enabled on the compile line.
    set_source_files_properties(
      "${PROJECT_SOURCE_DIR}/demo/detail/Sse.cpp"
      PROPERTIES COMPILE_FLAGS -fno-sanitize=address,undefined
    )
  elseif ("${CMAKE_CXX_COMPILER_ID}" MATCHES Clang)
    set(DEMO_LIBRARY_SANITIZE_ADDRESS ON)
    set(
      DEMO_ASAN_FLAGS
      -fno-common
      -fsanitize=address,undefined,integer,nullability
      -fno-sanitize=unsigned-integer-overflow
    )
    list(APPEND DEMO_CXX_FLAGS ${DEMO_ASAN_FLAGS})
  endif()
endif()

add_library(demo_deps INTERFACE)

find_package(fmt CONFIG)
if (NOT DEFINED fmt_CONFIG)
    # Fallback on a normal search on the current system
    find_package(Fmt MODULE REQUIRED)
endif()
target_link_libraries(demo_deps INTERFACE fmt::fmt)

list(REMOVE_DUPLICATES DEMO_INCLUDE_DIRECTORIES)
target_include_directories(demo_deps INTERFACE ${DEMO_INCLUDE_DIRECTORIES})
target_link_libraries(demo_deps INTERFACE
  ${DEMO_LINK_LIBRARIES}
  ${DEMO_SHINY_DEPENDENCIES}
  ${DEMO_ASAN_FLAGS}
)
