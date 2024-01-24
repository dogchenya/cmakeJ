# 添加可执行文件
add_executable(demo_test main.cpp)

# 链接 Folly 库到可执行文件
target_link_libraries(demo_test demo_deps)