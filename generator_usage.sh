#!/usr/bin/env bash
check_file_exists()
{
    FILE=$1
    if [ ! -f $FILE ]; then
        echo $FILE not found
        exit -1
    fi
}

check_symbol()
{
    FILE=$1
    SYM=$2
    if !(nm $FILE | grep $SYM > /dev/null); then
        echo "$SYM not founde in $FILE"
        exit -1
    fi
}

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/Users/hrttsh/Developper/halide/halide/bin
export DYLD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/Users/hrttsh/Developper/halide/halide/bin

#########################
# Basic generator usage #
#########################

# First let's compile the first generator for the host system:
./cmake-build-debug/halideGenerator -g my_first_generator -o . target=host

# That sound create a pair of files in the current directory:
# "my_first_generator.a", and "my_first_generator.h", which define a
# function "my_first_generator" representating the compiled pipelines

check_file_exists my_first_generator.a
check_file_exists my_first_generator.h
check_symbol my_first_generator.a my_first_generator

mkdir win32/
./cmake-build-debug/halideGenerator -g my_first_generator -f my_first_generator_win32 -o ./win32/ target=x86-32-windows

check_file_exists ./win32/my_first_generator_win32.lib
check_file_exists ./win32/my_first_generator.h

################################
# Generating pipeline variants #
################################

./cmake-build-debug/halideGenerator -g my_first_generator -e stmt -o . target=host

check_file_exists my_first_generator.stmt

# The second generator has generator params, which can be specified on the command-line after
# the target. Let's compile a few different variants:
./cmake-build-debug/halideGenerator -g my_second_generator -f my_second_generator_1 -o . target=host \
parallel=false scale=3.0 rotation=ccw output.type=uint16

./cmake-build-debug/halideGenerator -g my_second_generator -f my_second_generator_2 -o . target=host \
scale=9.0 rotation=ccw output.type=float32

./cmake-build-debug/halideGenerator -g my_second_generator -f my_second_generator_3 -o . target=host \
parallel=false output.type=float64

check_file_exists my_second_generator_1.a
check_file_exists my_second_generator_1.h
check_symbol my_second_generator_1.a my_second_generator_1
check_file_exists my_second_generator_2.a
check_file_exists my_second_generator_2.h
check_symbol      my_second_generator_2.a my_second_generator_2
check_file_exists my_second_generator_3.a
check_file_exists my_second_generator_3.h
check_symbol      my_second_generator_3.a my_second_generator_3

######################
# The Halide runtime #
######################

echo "The halide runtime:"
nm my_second_generator_1.a | grep "[SWT] _\?halide_"

check_runtime()
{
    if !(nm $1 | grep "[TSW] _\?halide_" > /dev/null); then
        echo "Halide runtime not found in $1"
        exit -1
    fi
}

check_no_runtime()
{
    if nm $1 | grep "[TSW] _\?halide_" > /dev/null; then
        echo "Halide runtime found in $1"
        exit-1
    fi
}

./cmake-build-debug/halideGenerator -g my_first_generator -f my_first_generator_basic \
-e o,h -o . target=host-x86-64-no_runtime

./cmake-build-debug/halideGenerator -g my_first_generator -f my_first_generator_sse41 \
-e o,h -o . target=host-x86-64-sse41-no_runtime

./cmake-build-debug/halideGenerator -g my_first_generator -f my_first_generator_avx \
-e o,h -o . target=host-x86-64-avx-no_runtime

check_no_runtime my_first_generator_basic.o
check_symbol     my_first_generator_basic.o my_first_generator_basic
check_no_runtime my_first_generator_sse41.o
check_symbol     my_first_generator_sse41.o my_first_generator_sse41
check_no_runtime my_first_generator_avx.o
check_symbol     my_first_generator_avx.o my_first_generator_avx

./cmake-build-debug/halideGenerator -r halide_runtime_x86 -e o,h -o . \
target=host-x86-64
check_runtime halide_runtime_x86.o

ar q my_first_generator_multi.a \
    my_first_generator_basic.o \
    my_first_generator_sse41.o \
    my_first_generator_avx.o \
    halide_runtime_x86.o

check_runtime my_first_generator_multi.a
check_symbol  my_first_generator_multi.a my_first_generator_basic
check_symbol  my_first_generator_multi.a my_first_generator_sse41
check_symbol  my_first_generator_multi.a my_first_generator_avx

echo "Success!"