# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "mgis_binaries"
version = v"1.0-master"

# Collection of sources required to build mgisBuilder
sources = [
    "https://github.com/thelfer/MFrontGenericInterfaceSupport.git" =>
    "64662f2c293d5a88fc6f1a21a51dab3fd9a0b8b3",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/MFrontGenericInterfaceSupport/

COMMON_FLAGS=\
'-DJlCxx_DIR=/workspace/destdir/lib/cmake/JlCxx '\
'-Denable-julia-bindings=ON '\
"-DCMAKE_INSTALL_PREFIX=$prefix "\
"-DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain"


if [ $target = "x86_64-w64-mingw32" ]; then
    cmake -DTFEL_INSTALL_PATH=/workspace/destdir/bin $COMMON_FLAGS
else
    cmake $COMMON_FLAGS
fi

make
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11))
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libMFrontGenericInterface", :libMFrontGenericInterface)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/TeroFrondelius/tfelBuilder/releases/download/Second_build/build_tfelBuilder.v3.2.1-master.jl",
    "https://github.com/JuliaInterop/libcxxwrap-julia/releases/download/v0.5.3/build_libcxxwrap-julia-1.0.v0.5.3.jl",
    "https://github.com/JuliaPackaging/JuliaBuilder/releases/download/v1.0.0-2/build_Julia.v1.0.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
