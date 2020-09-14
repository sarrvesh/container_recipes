FROM ubuntu:18.04

    ENV DEBIAN_FRONTEND=noninteractive
    ENV HDF5_USE_FILE_LOCKING=FALSE

    # Install common dependencies
    RUN apt-get update \
      && apt-get --yes install --no-install-recommends \
      bison \
      build-essential \
      cmake \
      eog \
      flex \
      g++ \
      gcc \
      gettext-base \
      gfortran \
      git \
      libarmadillo-dev \
      libblas-dev \
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
      python-tk \
      python-setuptools \
      subversion \
      vim \
      wcslib-dev \
      wget \
      && rm -rf /var/lib/apt/lists/*

    # Install python2 packages
    RUN pip install setuptools Cython
    RUN pip install --upgrade \
      aplpy \
      astropy \
      Jinja2 \
      numpy==1.16 \
      matplotlib \
      PySocks \
      python-monetdb \
      shapely \
      scipy \
      wcsaxes \
      xmlrunner
    
    # 
    RUN mkdir /opt/lofarsoft/
    
    # Install boost python 1.63 with python 2
    RUN cd / \
    && wget https://dl.bintray.com/boostorg/release/1.63.0/source/boost_1_63_0.tar.bz2 \
    && tar xvf boost_1_63_0.tar.bz2 \
    && cd boost_1_63_0 \
    && ./bootstrap.sh \
           --with-python=/usr/bin/python \
           --with-libraries=python,date_time,filesystem,system,program_options,test \
    && ./b2 install \
    && cd / && rm -r boost_1_63_0*
    
    # Install casacore data
    RUN mkdir -p /opt/lofarsoft/data \
    && cd /opt/lofarsoft/data \
    && wget ftp://anonymous@ftp.astron.nl/outgoing/Measures/WSRT_Measures.ztar \
    && tar xvf WSRT_Measures.ztar \
    && rm WSRT_Measures.ztar
    
    # Build casacore
    RUN cd / & wget https://github.com/casacore/casacore/archive/v2.4.1.tar.gz \
    && tar xvf v2.4.1.tar.gz && cd casacore-2.4.1 \
    && mkdir build && cd build \
    && cmake -DBUILD_PYTHON=True \
        -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft/ \
        -DDATA_DIR=/opt/lofarsoft/data \
        -DUSE_OPENMP=ON -DUSE_THREADS=OFF -DUSE_FFTW3=TRUE \
        -DUSE_HDF5=ON -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_PYTHON=True \
        -DCMAKE_CXX_FLAGS="-fsigned-char -O2 -DNDEBUG" ../ \
    && make -j4 && make install && cd / && rm -rf v3.2.1.tar.gz casacore-3.2.1
    
    # Install python casacore
    RUN cd / & wget https://github.com/casacore/python-casacore/archive/v3.2.0.tar.gz \
    && tar xvf v3.2.0.tar.gz && cd python-casacore-3.2.0 \
    && mkdir -p /opt/lofarsoft//lib/python2.7/site-packages/ \
    && export PYTHONPATH=/opt/lofarsoft//lib/python2.7/site-packages/ \
    && export LD_LIBRARY_PATH=/opt/lofarsoft/lib \
    && export PATH=/opt/lofarsoft/include:${PATH} \
    && python ./setup.py build_ext -I/opt/lofarsoft/include -L/opt/lofarsoft/lib \
    && python ./setup.py install --prefix=/opt/lofarsoft/ \
    && cd / && rm -rf python-casacore-3.2.0 v3.2.0.tar.gz
    
    # Install losoto
    RUN cd / && git clone https://github.com/revoltek/losoto.git \
    && cd losoto && git checkout pref3 \
    && export PYTHONPATH=/opt/lofarsoft//lib/python2.7/site-packages/ \
    && pip install tables==3.5.2 \
    && python setup.py install --prefix=/opt/lofarsoft/ && cd / && rm -rf losoto
    
    # Install aoflagger 2.14
    # NOTE: 2.15 NEEDS PYTHON 3!!!
    RUN wget https://sourceforge.net/projects/aoflagger/files/aoflagger-2.14.0/aoflagger-2.14.0.tar.bz2/download \
    && mv download download.tar && tar xvf download.tar \
    && cd aoflagger-2.14.0 && mkdir build && cd build \
    && export PYTHONPATH=/opt/lofarsoft//lib/python2.7/site-packages/ \
    && cmake -DCASACORE_ROOT_DIR=/opt/lofarsoft/ \
             -DPYTHON_EXECUTABLE=/usr/bin/python \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft ../ \
    && make -j8 && make install && cd / && rm -rf aoflagger-2.14.0 download.tar 
    
    # Install pyBDSF
    RUN wget https://github.com/lofar-astron/PyBDSF/archive/v1.9.2.tar.gz \
    && tar xvf v1.9.2.tar.gz && cd PyBDSF-1.9.2 \
    && export PYTHONPATH=/opt/lofarsoft//lib/python2.7/site-packages/ \
    && python setup.py install --prefix=/opt/lofarsoft/ \
    && cd / && rm -rf v1.9.2.tar.gz PyBDSF-1.9.2
    
    # Install the LOFAR Beam Library
    RUN git clone https://github.com/lofar-astron/LOFARBeam.git \
    && cd LOFARBeam \
    && mkdir build && cd build \
    && cmake -DCASACORE_ROOT_DIR=/opt/lofarsoft/ \
             -DPYTHON_EXECUTABLE=/usr/bin/python \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft/ ../ \
    && make && make install && cd / && rm -rf LOFARBeam
    
    # Install IDG
    RUN cd / && git clone https://gitlab.com/astron-idg/idg.git \
    && cd idg && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft/ ../ \
    && make && make install && cd / && rm -rf idg
    
    # Install dysco
    RUN cd / && wget https://github.com/aroffringa/dysco/archive/v1.2.tar.gz \
    && tar xvf v1.2.tar.gz && cd dysco-1.2 && mkdir build && cd build \
    && cmake -DCASACORE_ROOT_DIR=/opt/lofarsoft \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft ../ \
    && make && make install && cd / && rm -rf v1.2.tar.gz dysco-1.2
    
    # Install LSMTool
    RUN cd / && wget https://github.com/darafferty/LSMTool/archive/v1.4.2.tar.gz \
    && tar xvf v1.4.2.tar.gz && cd LSMTool-1.4.2 \
    && export PYTHONPATH=/opt/lofarsoft//lib/python2.7/site-packages/ \
    && python setup.py install --prefix=/opt/lofarsoft/ \
    && cd / && rm -rf LSMTool-1.4.2 v1.4.2.tar.gz
    
    # Install RMextract
    RUN cd / && git clone https://github.com/lofar-astron/RMextract.git \
    && cd RMextract \
    && export PYTHONPATH=/opt/lofarsoft//lib/python2.7/site-packages/ \
    && python setup.py install --prefix=/opt/lofarsoft && cd / && rm -rf RMextract 
    
    # Install LofarStMan
    RUN cd / && git clone https://github.com/lofar-astron/LofarStMan.git \
    && cd LofarStMan && mkdir -p build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft/ \
             -DCMAKE_PREFIX_PATH=/opt/lofarsoft ../ \
    && make && make install \
    && cd / && rm -rf LofarStMan
    
    # Install DP3 v4.1
    # NOTE DP3 4.2 requires PYTHON 3 !!!
    RUN cd / && wget https://github.com/lofar-astron/DP3/archive/v4.1.tar.gz \
    && tar xvf v4.1.tar.gz && cd DP3-4.1 && mkdir build && cd build \
    && cmake -DCASACORE_ROOT_DIR=/opt/lofarsoft/ \
             -DIDGAPI_LIBRARIES=/opt/lofarsoft/lib/libidg-api.so \
             -DIDGAPI_INCLUDE_DIRS=/opt/lofarsoft/include \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft/ ../ \
    && make -j8 && make install \
    && cd / && rm -rf DP3-4.1 v4.1.tar.gz 
    
    # Install wsclean
    RUN cd / && wget https://sourceforge.net/projects/wsclean/files/wsclean-2.8/wsclean-2.8.tar.bz2/download \
    && mv download download.tar && tar xvf download.tar \
    && cd wsclean-2.8 && mkdir build && cd build \
    && cmake -DCASACORE_ROOT_DIR=/opt/lofarsoft \
             -DIDGAPI_LIBRARIES=/opt/lofarsoft/lib/libidg-api.so \
             -DIDGAPI_INCLUDE_DIRS=/opt/lofarsoft/include \
             -DCMAKE_PREFIX_PATH=/opt/lofarsoft \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft ../ \
    && make -j4 && make install && cd / && rm -rf download.tar wsclean-2.8
    
    # Install LOFAR 3.2.1
    RUN cd / \
    && svn --non-interactive -q co \
      https://svn.astron.nl/LOFAR/branches/LOFAR-Release-3_2/ source 
    RUN cd / && mkdir -p source/build/gnucxx11_optarch \
    && cd source/build/gnucxx11_optarch \
    && cmake -DBUILD_PACKAGES="Pipeline ParmDB pyparmdb" \
             -DCASACORE_ROOT_DIR=/opt/lofarsoft \
             -DCMAKE_INSTALL_PREFIX=/opt/lofarsoft \
             -DBUILD_TESTING=OFF -DUSE_OPENMP=True ../../ \
    && make -j1 && make install && cd / && rm -rf source
    
    # Install factor
    RUN cd / && git clone https://github.com/lofar-astron/factor.git \
    && cd factor \
    && export PYTHONPATH=/opt/lofarsoft/lib/python2.7/site-packages/ \
    && python setup.py install --prefix=/opt/lofarsoft/ \
    && cd / && rm -rf factor
    
    # Setup environment variables
    ENV DEBIAN_FRONTEND=noninteractive
    ENV PYTHONPATH=/opt/lofarsoft//lib/python2.7/site-packages/
    ENV LD_LIBRARY_PATH=/opt/lofarsoft/lib:/usr/local/lib/
