cmake_minimum_required(VERSION 3.12)
project(halideGenerator)

set(CMAKE_CXX_STANDARD 14)

# コンパイラオプション
add_definitions("-std=c++11")
add_definitions("-fno-rtti")
add_definitions("-g")

# 環境変数設定
# Halide
set(ENV{PROJECT_NAME}       halideGenerator)
set(ENV{Halide_ROOT_DIR}    /Users/hrttsh/Developper/halide/halide)
set(ENV{Halide_INSTALL_DIR} $ENV{Halide_ROOT_DIR})
set(ENV{Halide_INCLUDE_DIR} $ENV{Halide_INSTALL_DIR}/include)
set(ENV{Halide_LIBRARY_DIR} $ENV{Halide_INSTALL_DIR}/bin)
set(ENV{Halide_TOOLS_DIR}   $ENV{Halide_ROOT_DIR}/tools)
# opencv
#set(ENV{OPENCV_ROOT_DIR}   /usr/local/Cellar/opencv/3.4.3)
#set(ENV{OPENCV_INSTALL_DIR} $ENV{OPENCV_ROOT_DIR})
#set(ENV{OPENCV_INCLUDE_DIR} $ENV{OPENCV_INSTALL_DIR}/include)
#set(ENV{OPENCV_LIBRARY_DIR} $ENV{OPENCV_INSTALL_DIR}/lib)
#set(ENV{OPENCV_BIN_DIR}     $ENV{OPENCV_INSTALL_DIR}/bin)

# インクルードパス設定
include_directories($ENV{Halide_INCLUDE_DIR})
include_directories($ENV{Halide_TOOLS_DIR})
#include_directories($ENV{OPENCV_INCLUDE_DIR})

# ライブラリパス設定
link_directories($ENV{Halide_LIBRARY_DIR})
#link_directories($ENV{OPENCV_LIBRARY_DIR})

# libpng関連
#find_package(PNG REQUIRED)
#if(PNG_FOUND)
#    include_directories(${PNG_INCLUDE_DIR})
#endif()

# 実行ファイル名とソース指定
add_executable($ENV{PROJECT_NAME} $ENV{Halide_TOOLS_DIR}/GenGen.cpp firstGenerator.cpp)

# リンク設定
target_link_libraries($ENV{PROJECT_NAME} Halide)
#target_link_libraries($ENV{PROJECT_NAME} pthread)
#target_link_libraries($ENV{PROJECT_NAME} dl)
#target_link_libraries($ENV{PROJECT_NAME} opencv_core)
#target_link_libraries($ENV{PROJECT_NAME} opencv_imgcodecs)
#target_link_libraries($ENV{PROJECT_NAME} opencv_highgui)
#target_link_libraries($ENV{PROJECT_NAME} opencv_imgproc)

#if(PNG_FOUND)
#    target_link_libraries($ENV{PROJECT_NAME} ${PNG_LIBRARY})
#endif()