FROM node:latest
WORKDIR /
# The Big APT Dependency One-Liner
RUN apt update && apt upgrade -y && apt install -y git wget curl g++ zlib1g-dev make automake autoconf patch grep bzip2 gzip unzip sox gfortran libtool subversion gawk python2.7 python3 python3-pip ffmpeg
# Make python2.7 the default. Needed to compile kaldi
RUN ln -s /usr/bin/python2.7 /usr/bin/python
# The Big Python Dependency One-Liner
RUN pip3 install pydub scipy gdown torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu
# One-Liner to install vocal-remover
RUN wget https://github.com/tsurumeso/vocal-remover/releases/download/v5.0.2/vocal-remover-v5.0.2.zip && unzip vocal-remover-v5.0.2.zip && rm vocal-remover-v5.0.2.zip && (cd vocal-remover/ && pip3 install -r requirements.txt)
# Download and Compile kaldi
RUN git clone https://github.com/kaldi-asr/kaldi.git kaldi --origin upstream
RUN (cd kaldi/tools && make -j `nproc`)
RUN (cd kaldi/tools && extras/install_irstlm.sh)
# Needed for Multiarch
RUN (cd kaldi/tools && (extras/install_mkl.sh || extras/install_openblas.sh))
RUN (cd kaldi/src && ./configure --shared)
RUN (cd kaldi/src && make depend -j `nproc`)
RUN (cd kaldi/src && make -j `nproc`)
# Download NUS AutoLyrixAlign AI Models
RUN gdown 1aotjNix3YwOK41ck7OTHYgIppD5jP9uK && tar -xvf NUSAutoLyrixAlign-patched.tar.gz && rm NUSAutoLyrixAlign-patched.tar.gz
# Make python the default. Needed to run AutoLyrixAlign
RUN rm /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python