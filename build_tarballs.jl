# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "mgisBuilder"
version = v"0.1.0"

# Collection of sources required to build mgisBuilder
sources = [
    "https://github.com/thelfer/MFrontGenericInterfaceSupport.git" =>
    "64662f2c293d5a88fc6f1a21a51dab3fd9a0b8b3",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/MFrontGenericInterfaceSupport/
if [ $target = "x86_64-w64-mingw32" ]; then
    cmake -DCMAKE_CXX_FLAGS=-isystem\ /workspace/destdir/bin -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain
else
    cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain
fi


make
make install



"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libMFrontGenericInterface", :libMFrontGenericInterface)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/TeroFrondelius/tfelBuilder/releases/download/Second_build/build_tfelBuilder.v3.2.1-master.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

