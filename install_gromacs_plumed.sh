#!/bin/bash

# ==========================================================

# GROMACS 2022.4 + PLUMED 2.8.1 Installation Script

# Tested on Debian / Ubuntu

#

# Everything installs inside:

# $HOME/software

#

# Author: Simple reproducible installation

# ==========================================================

echo "-------------------------------------------"
echo "STEP 1: Installing system dependencies"
echo "-------------------------------------------"

sudo apt update

sudo apt install -y 
build-essential 
gcc g++ 
make 
wget 
git 
cmake 
libfftw3-dev 
libfftw3-mpi-dev 
openmpi-bin 
libopenmpi-dev 
libgsl-dev

echo "-------------------------------------------"
echo "STEP 2: Creating software directory"
echo "-------------------------------------------"

mkdir -p $HOME/software
cd $HOME/software

echo "-------------------------------------------"
echo "STEP 3: Installing compatible CMake (3.26)"
echo "GROMACS 2022 does NOT work with CMake 4.x"
echo "-------------------------------------------"

wget https://github.com/Kitware/CMake/releases/download/v3.26.4/cmake-3.26.4.tar.gz

tar -xvf cmake-3.26.4.tar.gz

cd cmake-3.26.4

./bootstrap --prefix=$HOME/software/cmake

make -j$(nproc)

make install

# Add new cmake to PATH

export PATH=$HOME/software/cmake/bin:$PATH

echo "-------------------------------------------"
echo "STEP 4: Downloading and installing PLUMED 2.8.1"
echo "-------------------------------------------"

cd $HOME/software

wget https://github.com/plumed/plumed2/releases/download/v2.8.1/plumed-2.8.1.tgz

tar -xvf plumed-2.8.1.tgz

cd plumed-2.8.1

./configure --prefix=$HOME/software/plumed-2.8.1

make -j$(nproc)

make install

# Add PLUMED to environment

export PATH=$HOME/software/plumed-2.8.1/bin:$PATH
export LD_LIBRARY_PATH=$HOME/software/plumed-2.8.1/lib:$LD_LIBRARY_PATH

echo "-------------------------------------------"
echo "STEP 5: Downloading GROMACS 2022.4"
echo "-------------------------------------------"

cd $HOME/software

wget https://ftp.gromacs.org/gromacs/gromacs-2022.4.tar.gz

tar -xvf gromacs-2022.4.tar.gz

cd gromacs-2022.4

echo "-------------------------------------------"
echo "STEP 6: Patching GROMACS with PLUMED"
echo "-------------------------------------------"

plumed patch -p

echo "-------------------------------------------"
echo "STEP 7: Building GROMACS"
echo "-------------------------------------------"

mkdir build
cd build

cmake .. 
-DCMAKE_INSTALL_PREFIX=$HOME/software/gromacs-2022.4-plumed 
-DGMX_MPI=ON 
-DGMX_THREAD_MPI=OFF 
-DGMX_BUILD_OWN_FFTW=ON 
-DGMX_GPU=OFF

echo "-------------------------------------------"
echo "STEP 8: Compiling GROMACS"
echo "-------------------------------------------"

make -j$(nproc)

make install

echo "-------------------------------------------"
echo "STEP 9: Loading GROMACS environment"
echo "-------------------------------------------"

source $HOME/software/gromacs-2022.4-plumed/bin/GMXRC

echo "-------------------------------------------"
echo "STEP 10: Adding environment to .bashrc"
echo "-------------------------------------------"

echo 'export PATH=$HOME/software/cmake/bin:$PATH' >> ~/.bashrc
echo 'export PATH=$HOME/software/plumed-2.8.1/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$HOME/software/plumed-2.8.1/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'source $HOME/software/gromacs-2022.4-plumed/bin/GMXRC' >> ~/.bashrc

echo "-------------------------------------------"
echo "INSTALLATION COMPLETE"
echo "-------------------------------------------"

echo "Reload environment using:"
echo "source ~/.bashrc"

echo ""
echo "Check installation:"
echo "gmx --version"
echo "plumed --version"

echo ""
echo "Example run:"
echo "gmx_mpi mdrun -plumed plumed.dat"

echo "-------------------------------------------"

# Enabled GPU as well: 
export PATH=$HOME/software/cmake/bin:$PATH

cd ~/software/gromacs-2022.4
rm -rf build
mkdir build
cd build

cmake .. \
-DCMAKE_INSTALL_PREFIX=$HOME/software/gromacs-2022.4-plumed \
-DGMX_MPI=ON \
-DGMX_THREAD_MPI=OFF \
-DGMX_GPU=CUDA \
-DGMX_CUDA_TARGET_SM=86 \
-DGMX_BUILD_OWN_FFTW=ON

make -j$(nproc)
make install

source ~/software/gromacs-2022.4-plumed/bin/GMXRC
