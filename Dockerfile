FROM node:latest
WORKDIR /

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        git \
        wget \
        curl \
        g++ \
        zlib1g-dev \
        make \
        automake \
        autoconf \
        patch \
        grep \
        bzip2 \
        gzip \
        unzip \
        sox \
        gfortran \
        libtool \
        subversion \
        gawk \
        python2.7 \
        python3 \
        python3-pip \
        ffmpeg \
        ca-certificates \
        vim \
        nano && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN pip3 install pydub scipy gdown
RUN if [ `arch` = 'x86_64' ]; \
    then \
        pip3 install spleeter; \
    else \
        pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu && \
        wget https://github.com/tsurumeso/vocal-remover/releases/download/v5.0.2/vocal-remover-v5.0.2.zip && \
        unzip vocal-remover-v5.0.2.zip && \
        rm vocal-remover-v5.0.2.zip && \
        (cd vocal-remover/ && pip3 install -r requirements.txt);\
    fi

RUN git clone --depth 1 https://github.com/kaldi-asr/kaldi.git kaldi && \
    (cd kaldi/tools && make -j `nproc`) && \
    (cd kaldi/tools && extras/install_irstlm.sh) && \
    if [ `arch` = 'x86_64' ]; \
    then \
        (cd kaldi/tools && extras/install_mkl.sh); \
    else \
        (cd kaldi/tools && extras/install_openblas.sh); \
    fi && \
    (cd kaldi/src && ./configure --shared) && \
    (cd kaldi/src && make depend -j `nproc`) && \
    (cd kaldi/src && make -j `nproc`) && \
    find /kaldi -type f \( -name "*.o" -o -name "*.la" -o -name "*.a" \) -exec rm {} \; && \
    find /intel -type f -name "*.a" -exec rm {} \; && \
    find /intel -type f -regex '.*\(_mc.?\|_mic\|_thread\|_ilp64\)\.so' -exec rm {} \; && \
    rm -rf /kaldi/.git

RUN gdown 1aotjNix3YwOK41ck7OTHYgIppD5jP9uK && \
    tar -xvf NUSAutoLyrixAlign-patched.tar.gz && \
    rm NUSAutoLyrixAlign-patched.tar.gz