FROM python:2.7-slim

ARG NEUWARE_FILE=neuware-mlu270-1.5.0-1_Debian10_amd64.deb
ARG CAFFE_FILE=Cambricon-MLU270-caffe.tar.gz

ARG FILE_PATH=data

ADD ${FILE_PATH}/${NEUWARE_FILE} /opt/cambricon/${NEUWARE_FILE}
ADD ${FILE_PATH}/${CAFFE_FILE} /opt/cambricon

WORKDIR /opt/cambricon/

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
            && apt-get install -y  --no-install-recommends libboost-all-dev 
            # \
            # && apt purge -y neuware-mlu270 \
            # && rm -rf ./${NEUWARE_FILE} \
            # && apt-get clean \
            # && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
         numpy \
         scikit-image \
         protobuf \
	 scikit-learn \
         opencv-python==3.4.0.12 \
         pyyaml

RUN /bin/bash -c "\
    source env_caffe.sh \
    && cd /opt/cambricon/caffe/src/caffe/scripts/ \
    && chmod +x build_caffe_mlu270_cambricon_release.sh \
    && ./build_caffe_mlu270_cambricon_release.sh \
    "

ENV ROOT_HOME /opt/cambricon
ENV NEUWARE_HOME /usr/local/neuware
ENV CAFFE_HOME $ROOT_HOME/caffe
ENV DATASET_HOME $ROOT_HOME/datasets
ENV PYTHONPATH $PYTHONPATH:$CAFFE_HOME/src/caffe/python
ENV mcore "MLU200"
ENV PATH $PATH:$NEUWARE_HOME/bin
ENV LD_LIBRARY_PATH $NEUWARE_HOME/lib64:$CAFFE_HOME/lib:$LD_LIBRARY_PATH
ENV GLOG_alsologtostderr=true
ENV GLOG_minloglevel 0
ENV CAFFE_MODELS_DIR $ROOT_HOME/models/caffe
ENV VOC_PATH ${DATASET_HOME}/VOC2012/Annotations
ENV COCO_PATH ${DATASET_HOME}/COCO
ENV FDDB_PATH ${DATASET_HOME}/FDDB