FROM ubuntu:18.04

    ENV DEBIAN_FRONTEND=noninteractive
    ENV HDF5_USE_FILE_LOCKING=FALSE

    # Install common dependencies
    RUN apt-get update \
      && apt-get --yes install --no-install-recommends \
      bison \
      build-essential \
      cmake \
      flex \
      g++ \
      gcc \
      gettext-base \
      gfortran \
      git \
      libarmadillo-dev \
      libblas-dev \
      libboost-date-time-dev \
      libboost-dev \
      libboost-filesystem-dev \
      libboost-numpy-dev \
      libboost-program-options-dev \
      libboost-python-dev \
      libboost-regex-dev \
      libboost-signals-dev \
      libboost-system-dev \
      libboost-thread-dev \
      libboost-test-dev \
      libcfitsio-dev \
      libfftw3-dev \
      libgsl-dev \
      libgtkmm-3.0-dev \
      libhdf5-serial-dev \
      liblapacke-dev \
      liblog4cplus-1.1-9 \
      liblog4cplus-dev \
      libncurses5-dev \
      libpng-dev \
      libpython2.7-dev \
      libreadline-dev \
      libxml2-dev \
      openssh-server \
      python \
      python-pip \
      python3-pip \
      python-tk \
      python-setuptools \
      subversion \
      vim \
      wcslib-dev \
      wget \
      && rm -rf /var/lib/apt/lists/*

    # Install python3 packages
    RUN pip3 install setuptools
    RUN pip3 install numpy xmlrunner
    
    # Install python2 packages
    RUN pip install numpy

    # Install casacore data
    RUN mkdir -p /opt/lofarsoft/data \
    && cd /opt/lofarsoft/data \
    && wget ftp://anonymous@ftp.astron.nl/outgoing/Measures/WSRT_Measures.ztar \
    && tar xvf WSRT_Measures.ztar \
    && rm WSRT_Measures.ztar
    
    # Install casacore
    RUN cd / && wget https://github.com/casacore/casacore/archive/v3.1.0.tar.gz \
    && tar xvf v3.1.0.tar.gz && cd casacore-3.1.0 \
    && mkdir build && cd build \
    && cmake -DBUILD_PYTHON=True \
        -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft/ \
        -DDATA_DIR=/opt/lofarsoft/data \
        -DUSE_OPENMP=ON -DUSE_THREADS=OFF -DUSE_FFTW3=TRUE \
        -DUSE_HDF5=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_PYTHON3=True \
        -DCMAKE_CXX_FLAGS="-fsigned-char -O2 -DNDEBUG" ../ \
    && make -j8 && make install && cd / && rm -rf v3.1.0.tar.gz casacore-3.1.0
    
    # Install casarest
    RUN cd / && wget https://github.com/casacore/casarest/archive/1.5.0.tar.gz \
    && tar xvf 1.5.0.tar.gz && cd casarest-1.5.0 && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft/ \
             -DCMAKE_PREFIX_PATH=/opt/lofarsoft/ ../ \
    && make -j8 && make install && cd / && rm -rf casarest-1.5.0 1.5.0.tar.gz

    # Install python casacore for python3
    RUN wget https://github.com/casacore/python-casacore/archive/v3.0.0.tar.gz \
    && mkdir -p /opt/lofarsoft//lib/python3.6/site-packages/ \
    && tar xvf v3.0.0.tar.gz && cd python-casacore-3.0.0 \
    && export PYTHONPATH=/opt/lofarsoft//lib/python3.6/site-packages/ \
    && python3 setup.py build_ext -I/opt/lofarsoft/include -L/opt/lofarsoft/lib \
    && python3 setup.py install --prefix=/opt/lofarsoft/ \
    && cd / && rm -rf python-casacore-3.0.0 v3.0.0.tar.gz
    
    # Install aoflagger
    RUN wget https://sourceforge.net/projects/aoflagger/files/latest/download \
    && mv download download.tar && tar xvf download.tar \
    && cd aoflagger-2.14.0 && mkdir build && cd build \
    && cmake -DCASACORE_ROOT_DIR=/opt/lofarsoft/ \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft ../ \
    && make -j8 && make install && cd / && rm -rf aoflagger-2.14.0
    
    # Install pyBDSF
    RUN wget https://github.com/lofar-astron/PyBDSF/archive/v1.9.0.tar.gz \
    && tar xvf v1.9.0.tar.gz && cd PyBDSF-1.9.0 \
    && export PYTHONPATH=/opt/lofarsoft//lib/python3.6/site-packages/ \
    && python3 setup.py install --prefix=/opt/lofarsoft/ \
    && cd / && rm -rf v1.9.0.tar.gz PyBDSF-1.9.0
    
    # Install the LOFAR Beam Library
    RUN git clone https://github.com/lofar-astron/LOFARBeam.git \
    && cd LOFARBeam \
    && mkdir build && cd build \
    && cmake -DCASACORE_ROOT_DIR=/opt/lofarsoft/ \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft/ ../ \
    && make && make install && cd / && rm -rf LOFARBeam
    
    # Install IDG
    RUN cd / && git clone https://gitlab.com/astron-idg/idg.git \
    && cd idg && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft/ ../ \
    && make && make install && cd / && rm -rf idg
    
    # Install DP3
    RUN git clone https://github.com/lofar-astron/DP3.git \
    && cd DP3 && mkdir build && cd build \
    && cmake -DCASACORE_ROOT_DIR=/opt/lofarsoft/ \
             -DIDGAPI_LIBRARIES=/opt/lofarsoft/lib/libidg-api.so \
             -DIDGAPI_INCLUDE_DIRS=/opt/lofarsoft/include \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft/ ../ \
    && make -j8 && make install \
    && cd / && rm -rf DP3 
    
    # Install wsclean
    RUN cd / && wget https://sourceforge.net/projects/wsclean/files/wsclean-2.7/wsclean-2.7.tar.bz2/download \
    && mv download download.tar && tar xvf download.tar \
    && cd wsclean-2.7 && mkdir build && cd build \
    && cmake -DCASACORE_ROOT_DIR=/opt/lofarsoft \
             -DIDGAPI_LIBRARIES=/opt/lofarsoft/lib/libidg-api.so \
             -DIDGAPI_INCLUDE_DIRS=/opt/lofarsoft/include \
             -DCMAKE_PREFIX_PATH=/opt/lofarsoft \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft ../ \
    && make -j4 && make install && cd / && rm -rf download.tar wsclean-2.7
    
    # Install dysco
    RUN cd / && wget https://github.com/aroffringa/dysco/archive/v1.2.tar.gz \
    && tar xvf v1.2.tar.gz && cd dysco-1.2 && mkdir build && cd build \
    && cmake -DCASACORE_ROOT_DIR=/opt/lofarsoft \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft ../ \
    && make && make install && cd / && rm -rf v1.2.tar.gz dysco-1.2
    
    # Install LSMTool
    RUN cd / && wget https://github.com/darafferty/LSMTool/archive/v1.4.1.tar.gz \
    && tar xvf v1.4.1.tar.gz && cd LSMTool-1.4.1 \
    && export PYTHONPATH=/opt/lofarsoft//lib/python3.6/site-packages/ \
    && python3 setup.py install --prefix=/opt/lofarsoft/ \
    && cd / && rm -rf LSMTool-1.4.1 v1.4.1.tar.gz
    
    # Install RMextract
    RUN cd / && git clone https://github.com/lofar-astron/RMextract.git \
    && cd RMextract && git checkout v0.4 \
    && export PYTHONPATH=/opt/lofarsoft//lib/python3.6/site-packages/ \
    && python3 setup.py install --prefix=/opt/lofarsoft && cd / && rm -rf RMextract 
    
    # Install losoto
    RUN cd / && git clone https://github.com/revoltek/losoto.git \
    && cd losoto && git checkout 8d34d0b2f789d166ecc80b9d256c4df743ea5076 \
    && export PYTHONPATH=/opt/lofarsoft//lib/python3.6/site-packages/ \
    && python3 setup.py install --prefix=/opt/lofarsoft/ && cd / && rm -rf losoto
    
    # Install LOFAR 4 from trunk
    RUN cd / \
    && svn --non-interactive -q co \
      https://svn.astron.nl/LOFAR/branches/LOFAR-Release-4_0/ source 
    RUN cd / && mkdir -p source/build/gnucxx11_optarch \
    && cd source/build/gnucxx11_optarch \
    && cmake -DBUILD_PACKAGES="MS ParmDB pyparmdb Pipeline LofarStMan" \
             -DCASACORE_ROOT_DIR=/opt/lofarsoft \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft \
             -DBUILD_TESTING=OFF -DUSE_OPENMP=True ../../ \
    && make -j8 && make install && cd ../../../ && rm -rf source
