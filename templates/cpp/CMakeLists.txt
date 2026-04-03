if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build" FORCE)
endif()

cmake_minimum_required(VERSION 3.10)
project(my_project VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Example: Adding a library (e.g., fmt)
# find_package(fmt REQUIRED)
find_package(doctest REQUIRED)

# Source files
add_executable(my_project src/main.cpp)

# Enable testing
enable_testing()

# Create a test executable
add_executable(unit_tests
    tests/test_main.cpp
    tests/example_test.cpp
)
target_link_libraries(unit_tests PRIVATE doctest::doctest)

# Register the test executable with CTest
add_test(NAME tests COMMAND unit_tests)

# Example: Linking a library
# target_link_libraries(my_project PRIVATE fmt::fmt)

# Example: enable all warnings
if(MSVC)
    target_compile_options(my_project PRIVATE /W4)
else()
    target_compile_options(my_project PRIVATE -Wall -Wextra -Wpedantic)
endif()

install(TARGETS my_project DESTINATION bin)
