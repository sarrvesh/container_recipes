FROM ubuntu:20.04

    ENV DEBIAN_FRONTEND=noninteractive
    ENV HDF5_USE_FILE_LOCKING=FALSE

    # Install common dependencies
    RUN apt-get update \
    && apt-get --yes install --no-install-recommends \
        libblas-dev \
        liblapacke-dev \
        build-essential \
        casacore-data \
        casacore-dev \
        cmake \
        git \
        g++ \
        gfortran \
        python3-casacore \
        python3-dev \
        python3-pip \
        python3-setuptools \
        vim \
        wget \
        libcfitsio-dev \
        libgsl-dev \
        libhdf5-dev \
        libfftw3-dev \
        libboost-dev \
        libboost-date-time-dev \
        libboost-filesystem-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        montage \
    && rm -rf /var/lib/apt/lists/*

    # Install python3 packages
    RUN pip3 install -U pip
    RUN pip3 install -U astroplan numpy astropy matplotlib ipython

    # Download NRAO CASA
    RUN pip3 install casatasks==6.5.3.28
    RUN pip3 install casadata

    # Install Everybeam
    RUN cd / && git clone https://git.astron.nl/RD/EveryBeam.git \
    && cd EveryBeam && git checkout v0.5.3 \
    && mkdir build && cd build \
    && cmake ../ \
    && make -j $threads && make install \
    && cd / && rm -rf EveryBeam

    # Install IDG
    RUN cd / && git clone https://gitlab.com/astron-idg/idg.git \
    && cd idg && git checkout 1.2.0 \
    && mkdir build && cd build \
    && cmake \
      -DBUILD_LIB_CUDA=Off \
      ../ \
    && make && make install && cd / && rm -rf idg

    # Install wsclean
    RUN cd / && git clone https://gitlab.com/aroffringa/wsclean.git \
    && cd wsclean && git checkout v3.4 \
    && mkdir build && cd build \
    && cmake ../ \
    && make -j 4 && make install \
    && cd / && rm -rf wsclean

    # Install BDSF
    RUN pip3 install bdsf
    
    # Install breizorro
    RUN pip3 install breizorro

    # Install mosaic-queen
    RUN pip3 install mosaic-queen
    
    # Setup environment variables
    ENV DEBIAN_FRONTEND=noninteractive
