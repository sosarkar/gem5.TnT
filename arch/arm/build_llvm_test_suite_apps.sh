#!/usr/bin/env bash

# Copyright (c) 2018, University of Kaiserslautern
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Author: Éder F. Zulian

DIR="$(cd "$(dirname "$0")" && pwd)"
TOPDIR=$DIR/../..
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in

toolchain=gcc-linaro-5.4.1-2017.05-x86_64_aarch64-linux-gnu
toolchaintarball=$toolchain.tar.xz

wgethis=(
"$TOOLCHAINSDIR_ARM:https://releases.linaro.org/components/toolchain/binaries/5.4-2017.05/aarch64-linux-gnu/$toolchaintarball"
)

gitrepos=(
"$BENCHMARKSDIR:http://llvm.org/git/test-suite.git"
)

greetings
wget_into_dir wgethis[@]
git_clone_into_dir gitrepos[@]

toolchaindir=$TOOLCHAINSDIR_ARM/$toolchain
if [[ ! -d $toolchaindir ]]; then
	tar -xaf $TOOLCHAINSDIR_ARM/$toolchaintarball -C $TOOLCHAINSDIR_ARM
fi

get_num_procs np

cd $BENCHMARKSDIR/test-suite
git checkout release_50

cd $BENCHMARKSDIR/test-suite/SingleSource/Benchmarks/Stanford
cat > Makefile << EOM
sysroot=$toolchaindir/aarch64-linux-gnu/libc
cc=$toolchaindir/bin/aarch64-linux-gnu-gcc
sources=\$(wildcard *.c)
bins=\$(patsubst %.c,%,\$(sources))
all: \$(bins)
	@echo Done.
%: %.c
	\$(cc) --sysroot=\$(sysroot) --no-sysroot-suffix --static \$< -o \$@
clean:
	rm -rf \$(bins)
EOM
make clean > /dev/null 2>&1
make -j$np > /dev/null 2>&1

cd $BENCHMARKSDIR/test-suite/SingleSource/Benchmarks/CoyoteBench
cat > Makefile << EOM
LDLIBS += -lm -lstdc++
sysroot=$toolchaindir/aarch64-linux-gnu/libc
cc=$toolchaindir/bin/aarch64-linux-gnu-gcc
sources=\$(wildcard *.c)
bins=\$(patsubst %.c,%,\$(sources))
all: \$(bins)
	@echo Done.
%: %.c
	\$(cc) --sysroot=\$(sysroot) --no-sysroot-suffix --static \$< -o \$@ \$(LDLIBS)
clean:
	rm -rf \$(bins)
EOM
make clean > /dev/null 2>&1
make -j$np > /dev/null 2>&1

cd $BENCHMARKSDIR/test-suite/SingleSource/Benchmarks/Dhrystone
cat > Makefile << EOM
LDLIBS += -lm
sysroot=$toolchaindir/aarch64-linux-gnu/libc
cc=$toolchaindir/bin/aarch64-linux-gnu-gcc
sources=\$(wildcard *.c)
bins=\$(patsubst %.c,%,\$(sources))
all: \$(bins)
	@echo Done.
%: %.c
	\$(cc) --sysroot=\$(sysroot) --no-sysroot-suffix --static \$< -o \$@ \$(LDLIBS)
clean:
	rm -rf \$(bins)
EOM
make clean > /dev/null 2>&1
make -j$np > /dev/null 2>&1

cd $BENCHMARKSDIR/test-suite/SingleSource/Benchmarks/Linpack
cat > Makefile << EOM
LDLIBS += -lm
sysroot=$toolchaindir/aarch64-linux-gnu/libc
cc=$toolchaindir/bin/aarch64-linux-gnu-gcc
sources=\$(wildcard *.c)
bins=\$(patsubst %.c,%,\$(sources))
all: \$(bins)
	@echo Done.
%: %.c
	\$(cc) --sysroot=\$(sysroot) --no-sysroot-suffix --static \$< -o \$@ \$(LDLIBS)
clean:
	rm -rf \$(bins)
EOM
make clean > /dev/null 2>&1
make -j$np > /dev/null 2>&1

cd $BENCHMARKSDIR/test-suite/SingleSource/Benchmarks/McGill
cat > Makefile << EOM
FP_TOLERANCE := 0.001
LDLIBS += -lm
sysroot=$toolchaindir/aarch64-linux-gnu/libc
cc=$toolchaindir/bin/aarch64-linux-gnu-gcc
sources=\$(wildcard *.c)
bins=\$(patsubst %.c,%,\$(sources))
all: \$(bins)
	@echo Done.
%: %.c
	\$(cc) --sysroot=\$(sysroot) --no-sysroot-suffix --static \$< -o \$@ \$(LDLIBS)
clean:
	rm -rf \$(bins)
EOM
make clean > /dev/null 2>&1
make -j$np > /dev/null 2>&1
echo "Done."
