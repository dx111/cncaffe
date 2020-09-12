FROM python:2.7-slim

ARG NEUWARE_FILE=neuware-mlu270-1.4.0-1_Debian10_amd64.deb 
ARG CAFFE_FILE=Cambricon-MLU270-caffe.tar.gz 
ARG ENV_SH=env_caffe.sh
ARG BUILD_SH=/data/caffe/src/caffe/scripts/build_caffe_mlu270_cambricon_release.sh

ARG FILE_PATH=http://119.3.129.170:9000/public

ADD  ${FILE_PATH}/${NEUWARE_FILE} /data/${NEUWARE_FILE}

WORKDIR /data

RUN apt install ./${NEUWARE_FILE} \
            && apt update \
            && apt install -y \
            # cambricon software 
                                        cndrv \
                                        cnrt \
                                        cnml \
                                        cnplugin \
                                        cncodec \
                                        cndev \
                                        cnpapi \
                                        cnperf \
                                        cnlicense \
            # third part software
                                        patch  \ 
                                        build-essential  \
                                        cmake  \
                                        libgflags-dev \
                                        libgoogle-glog-dev \
                                        libprotobuf-dev \
                                        protobuf-compiler \
                                        libhdf5-serial-dev \
                                        liblmdb-dev \
                                        libleveldb-dev \
                                        libsnappy-dev \
                                        libopencv-dev \
                                        libopenblas-dev  \
                                        libatlas-base-dev \
            && apt-get install -y  --no-install-recommends libboost-all-dev \
            && apt purge -y neuware-mlu270 \
            && rm -rf ./${NEUWARE_FILE} \
            && apt-get clean \
            && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
         numpy \
         scikit-image \
         protobuf

ADD ${FILE_PATH}/${CAFFE_FILE} /data

RUN echo -e "if [ -f /data/env_caffe.sh ]; then\n./data/env_caffe.sh\nfi" >> ~.bashrc


RUN /bin/bash -c "\
    && chmod +x ${BUILD_SH} \
    && ${BUILD_SH} \
    && cd /data/caffe/src/caffe/build \
    && make install \
    "