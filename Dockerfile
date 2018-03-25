FROM continuumio/anaconda3:5.0.1

ADD patches/ /tmp/patches/
ADD patches/nbconvert-extensions.tpl /opt/kaggle/nbconvert-extensions.tpl

    # Use a fixed apt-get repo to stop intermittent failures due to flaky httpredir connections,
    # as described by Lionel Chan at http://stackoverflow.com/a/37426929/5881346
RUN sed -i "s/httpredir.debian.org/debian.uchicago.edu/" /etc/apt/sources.list && \
    apt-get update && apt-get install -y build-essential && \
    # https://stackoverflow.com/a/46498173
    conda update -y conda && conda update -y python && \
    # Vowpal Rabbit
    #apt-get install -y libboost-program-options-dev zlib1g-dev libboost-python-dev && \
    #cd /usr/lib/x86_64-linux-gnu/ && rm -f libboost_python.a && rm -f libboost_python.so && \
    #ln -sf libboost_python-py34.so libboost_python.so && ln -sf libboost_python-py34.a libboost_python.a && \
    #pip install vowpalwabbit && \
    # Anaconda's scipy is currently behind the main release (1.0)
    pip install scipy --upgrade && \
    pip install seaborn python-dateutil dask pytagcloud pyyaml joblib \
    husl geopy ml_metrics mne pyshp gensim && \
    conda install -y -c conda-forge spacy && python -m spacy download en && \
    python -m spacy download en_core_web_lg && \
    # The apt-get version of imagemagick is out of date and has compatibility issues, so we build from source
    apt-get -y install dbus fontconfig fontconfig-config fonts-dejavu-core fonts-droid ghostscript gsfonts hicolor-icon-theme \
libavahi-client3 libavahi-common-data libavahi-common3 libcairo2 libcap-ng0 libcroco3 \
libcups2 libcupsfilters1 libcupsimage2 libdatrie1 libdbus-1-3 libdjvulibre-text libdjvulibre21 libfftw3-double3 libfontconfig1 \
libfreetype6 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgomp1 libgraphite2-3 libgs9 libgs9-common libharfbuzz0b libijs-0.35 \
libilmbase6 libjasper1 libjbig0 libjbig2dec0 libjpeg62-turbo liblcms2-2 liblqr-1-0 libltdl7 libmagickcore-6.q16-2 \
libmagickcore-6.q16-2-extra libmagickwand-6.q16-2 libnetpbm10 libopenexr6 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 \
libpaper-utils libpaper1 libpixman-1-0 libpng12-0 librsvg2-2 librsvg2-common libthai-data libthai0 libtiff5 libwmf0.2-7 \
libxcb-render0 libxcb-shm0 netpbm poppler-data p7zip-full && \
    cd /usr/local/src && \
    wget http://transloadit.imagemagick.org/download/ImageMagick.tar.gz && \
    tar xzf ImageMagick.tar.gz && cd `ls -d ImageMagick-*` && pwd && ls -al && ./configure && \
    make -j $(nproc) && make install && \
    # clean up ImageMagick source files
    cd ../ && rm -rf ImageMagick* && \
    apt-get -y install libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev && \
    apt-get -y install libtbb2 libtbb-dev libjpeg-dev libtiff-dev libjasper-dev && \
    apt-get -y install cmake && \
    cd /usr/local/src && git clone --depth 1 https://github.com/Itseez/opencv.git && \
    cd opencv && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D WITH_FFMPEG=OFF -D WITH_V4L=ON -D WITH_QT=OFF -D WITH_OPENGL=ON -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.6m.so -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.6m/ -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.6m.so -D PYTHON_INCLUDE_DIR=/opt/conda/include/python3.6m/ -D BUILD_PNG=TRUE .. && \
    make -j $(nproc) && make install && \
    echo "/usr/local/lib/python3.6/site-packages" > /etc/ld.so.conf.d/opencv.conf && ldconfig && \
    cp /usr/local/lib/python3.6/site-packages/cv2.cpython-36m-x86_64-linux-gnu.so /opt/conda/lib/python3.6/site-packages/ && \
    # Clean up install cruft
    rm -rf /usr/local/src/opencv && \
    rm -rf /root/.cache/pip/* && \
    apt-get autoremove -y && apt-get clean
