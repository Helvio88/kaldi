FROM ubuntu:latest
WORKDIR /
RUN apt update && apt upgrade -y
RUN apt install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install -y git wget curl g++ zlib1g-dev make automake autoconf patch grep bzip2 gzip unzip sox gfortran libtool subversion gawk python2.7 python3 python3-pip ffmpeg nodejs
RUN ln -s /usr/bin/python2.7 /usr/bin/python
RUN pip3 install pydub scipy gdown
RUN git clone https://github.com/kaldi-asr/kaldi.git kaldi --origin upstream
RUN (cd kaldi/tools && make -j `nproc`)
RUN (cd kaldi/tools && extras/install_irstlm.sh)
RUN (cd kaldi/tools && (extras/install_mkl.sh || extras/install_openblas.sh))
RUN (cd kaldi/src && ./configure --shared)
RUN (cd kaldi/src && make depend -j `nproc`)
RUN (cd kaldi/src && make -j `nproc`)
RUN gdown 1aotjNix3YwOK41ck7OTHYgIppD5jP9uK && tar -xvf NUSAutoLyrixAlign-patched.tar.gz && rm NUSAutoLyrixAlign-patched.tar.gz
RUN rm /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python