using BinaryBuilder, Pkg

name = "Channelflow"
version = v"1.0.2" 

# 1. Get channelflow source
sources = [
    GitSource("https://github.com/TonehavenE/channelflow.git", "91ba77f93bba73af4ef25e3d3cecf35521badbfd"),
	GitSource("https://github.com/johnfgibson/CloudAtlas.jl", "42cd8a72cc3cfdd0c2c2de7759be291108e4b96c"),
	DirectorySource("./chflow_utils/")
    # GitSource("https://github.com/your-username/channelflow_c_api.git", "commit-hash-here")
]

# 2. The build script
script = raw"""
cd $WORKSPACE/srcdir/channelflow

mkdir build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX=$prefix \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DCMAKE_BUILD_TYPE=Release \
    -DEIGEN3_INCLUDE_DIR=$prefix/include/eigen3 \
	-DCMAKE_CXX_FLAGS="-Wno-error=unused-but-set-variable -Wno-error=unused-variable" \
    -DUSE_MPI=OFF

make -j${nproc}
make install
cd $WORKSPACE/srcdir
make projectfield
make projectseries
cp projectfield $WORKSPACE/destdir/bin/
cp projectseries $WORKSPACE/destdir/bin/
"""

# 3. Platforms
platforms = [
    Platform("x86_64", "linux"; libc = "glibc"),
    Platform("aarch64", "linux"; libc = "glibc"),
    Platform("x86_64", "freebsd"; ),
    Platform("aarch64", "freebsd"; ),
    # Platform("i686", "windows"; ),
    # Platform("x86_64", "windows"; )
]

platforms = expand_cxxstring_abis(platforms)

products = [
			# programs
			ExecutableProduct("continuesoln", :continuesoln),
			ExecutableProduct("findsoln", :findsoln),
			ExecutableProduct("findeigenvals", :findeigenvals),
			ExecutableProduct("simulateflow", :simulateflow),
			ExecutableProduct("edgetracking", :edgetracking),
			# tools
			ExecutableProduct("addfields", :addfields),
			ExecutableProduct("benchmark", :benchmark),
			ExecutableProduct("changegrid", :changegrid),
			ExecutableProduct("diffop", :diffop),
			ExecutableProduct("extrapolatefields", :extrapolatefields),
			ExecutableProduct("fieldconvert", :fieldconvert),
			ExecutableProduct("fieldprops", :fieldprops),
			ExecutableProduct("findsymmetries", :findsymmetries),
			ExecutableProduct("benchmark", :L2op),
			ExecutableProduct("optphaseshift", :optphaseshift),
			ExecutableProduct("perturbfield", :perturbfield),
			ExecutableProduct("pressure", :pressure),
			ExecutableProduct("randomfield", :randomfield),
			ExecutableProduct("symmetrize", :symmetrize),
			ExecutableProduct("symmetryop", :symmetryop),
			# CloudAtlas extras
			ExecutableProduct("projectfield", :projectfield),
			ExecutableProduct("projectseries", :projectseries),
		   ]
# 4. Dependencies
# This is the best part! BinaryBuilder handles all C dependencies.
# Channelflow needs FFTW and HDF5.
dependencies = [
    Dependency("FFTW_jll"),
    Dependency("HDF5_jll"),
    Dependency("Eigen_jll"),
    Dependency("NetCDF_jll"),
]

# 5. Build!
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.7", preferred_gcc_version = v"14.2.1")
