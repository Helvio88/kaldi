FROM ubuntu:latest
WORKDIR /
RUN apt update && apt upgrade -y && apt install -y git wget curl g++ zlib1g-dev make automake autoconf patch grep bzip2 gzip unzip sox gfortran libtool subversion gawk python2.7 python3 python3-pip
RUN ln -s /usr/bin/python2.7 /usr/bin/python
RUN pip3 install pydub scipy numpy
RUN git clone https://github.com/kaldi-asr/kaldi.git kaldi --origin upstream
RUN (cd kaldi/tools && make -j `nproc`)
RUN (cd kaldi/tools && extras/install_irstlm.sh)
RUN (cd kaldi/tools && (extras/install_mkl.sh || extras/install_openblas.sh))
RUN (cd kaldi/src && ./configure --shared)
RUN (cd kaldi/src && make depend -j `nproc`)
RUN (cd kaldi/src && make -j `nproc`)
