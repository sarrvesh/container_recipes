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

    # 
    RUN mkdir /opt/soft/

    # Install python3 packages
    RUN pip3 install -U pip
    RUN pip3 install astroplan numpy astropy matplotlib ipython

    # Download NRAO CASA
    RUN pip3 install casatasks==6.5.3.28
    RUN pip3 install casadata

    # Install Everybeam
    RUN cd / && git clone https://git.astron.nl/RD/EveryBeam.git \
    && cd EveryBeam && git checkout v0.5.2 \
    && mkdir build && cd build \
    && export PYTHONPATH=/opt/soft/lib/python3.8/site-packages/ \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/soft/ ../ \
    && make -j $threads && make install \
    && cd / && rm -rf EveryBeam

    # Install IDG
    RUN cd / && git clone https://gitlab.com/astron-idg/idg.git \
    && cd idg && git checkout 1.2.0 \
    && mkdir build && cd build \
    && cmake \
      -DCMAKE_INSTALL_PREFIX=/opt/soft/ \
      -DBUILD_LIB_CUDA=Off \
      ../ \
    && make && make install && cd / && rm -rf idg

    # Install wsclean
    RUN cd / && git clone https://gitlab.com/aroffringa/wsclean.git \
    && cd wsclean && git checkout a5b4e037d718aa1e15c79abc5e3cb0df240b3937 \
    && mkdir build && cd build \
    && export PYTHONPATH=/opt/soft/lib/python3.8/site-packages/ \
    && cmake \
        -DCMAKE_PREFIX_PATH=/opt/soft/ \
        -DCASACORE_ROOT_DIR=/opt/soft/ \
        -DCMAKE_INSTALL_PREFIX=/opt/soft/ ../ \
    && make -j 4 && make install \
    && cd / && rm -rf wsclean

    # Install BDSF
    RUN pip3 install bdsf
    
    # Install breizorro
    RUN pip3 install breizorro

    # Install KATbeam
    RUN cd / && git clone https://github.com/ska-sa/katbeam.git \
    && cd katbeam && git checkout 5ce6fcc35471168f4c4b84605cf601d57ced8d9e \
    && export PYTHONPATH=/opt/soft/lib/python3.8/site-packages/ \
    && python3 ./setup.py install --prefix=/opt/soft \
    && cd / && rm -rf katbeam

    # Install mosaic-queen
    RUN pip3 install mosaic-queen
    
    # Setup environment variables
    ENV DEBIAN_FRONTEND=noninteractive
    ENV PYTHONPATH=/opt/soft/lib/python3.8/site-packages/
    ENV LD_LIBRARY_PATH=/opt/soft/lib:/usr/local/lib/
