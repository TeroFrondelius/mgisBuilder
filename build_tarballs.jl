# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "mgis_binaries"
version = v"1.0-master"

# Collection of sources required to build mgisBuilder
sources = [
    "https://github.com/thelfer/MFrontGenericInterfaceSupport.git" =>
    "2e4313f91bc29a57d63c0dc1bd0ae6aa1d771c2d",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/MFrontGenericInterfaceSupport/

COMMON_FLAGS=\
'-DJlCxx_DIR=/workspace/destdir/lib/cmake/JlCxx '\
'-Denable-julia-bindings=ON '\
"-DCMAKE_INSTALL_PREFIX=$prefix "\
"-DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain "\
"-DMGIS_JULIA_MODULES_INSTALL_DIRECTORY=$prefix/lib"


if [ $target = "x86_64-w64-mingw32" ] || [ $target = "i686-w64-mingw32" ]; then
    sed -i -e "\$aset(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} -march=native\")" CMakeLists.txt
    cmake -DTFEL_INSTALL_PATH=$prefix/bin $COMMON_FLAGS
else
    cmake $COMMON_FLAGS
fi

make
make install

"""
# >&2 "error to get in debug mode"

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    # Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11))
    # Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11))
    Windows(:i686, compiler_abi=CompilerABI(:gcc7, :cxx11))
    # Windows(:x86_64, compiler_abi=CompilerABI(:gcc7, :cxx11))
    # MacOS(compiler_abi=CompilerABI(:gcc7, :cxx11))
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libMFrontGenericInterface", :libMFrontGenericInterface)
    LibraryProduct(prefix, "mgis-julia.so", :mgisjulia)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/TeroFrondelius/tfelBuilder/releases/download/v0.3.0/build_tfel_binaries.v3.2.1-master.jl",
    "https://github.com/JuliaInterop/libcxxwrap-julia/releases/download/v0.5.3/build_libcxxwrap-julia-1.0.v0.5.3.jl",
    "https://github.com/JuliaPackaging/JuliaBuilder/releases/download/v1.0.0-2/build_Julia.v1.0.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
