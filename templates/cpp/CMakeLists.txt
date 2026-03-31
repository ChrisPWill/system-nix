cmake_minimum_required(VERSION 3.10)
project(my_project VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
add_executable(my_project src/main.cpp)

# Example: enable all warnings
if(MSVC)
    target_compile_options(my_project PRIVATE /W4)
else()
    target_compile_options(my_project PRIVATE -Wall -Wextra -Wpedantic)
endif()
