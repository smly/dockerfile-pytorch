FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
LABEL maintainer="smly <i@ho.lc>"

# packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    apt-utils \
    bc \
    bzip2 \
    ca-certificates \
    curl \
    git \
    libgdal-dev \
    libssl-dev \
    libffi-dev \
    libncurses-dev \
    libgl1 \
    jq \
    cmake \
    parallel \
    python-dev \
    python-pip \
    python-wheel \
    python-setuptools \
    unzip \
    vim \
	tmux \
    wget \
    build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]
ENV PATH /opt/conda/bin:$PATH

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.7.10-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

RUN conda update conda && \
    conda config --add channels conda-forge

RUN pip install PyYAML

RUN conda install mkl mkl-include mkl-service mkl_fft mkl_random blas numpy
RUN conda install pytorch torchvision cudatoolkit=10.0 -c pytorch

# ENV CUDA_VERSION 10.0
# ENV TORCH_CUDA_ARCH_LIST 6.0;6.1;7.0;7.5
#
# RUN cd ~/ &&\
#     git clone --recursive http://github.com/pytorch/pytorch &&\
#     cd pytorch &&\
#     git checkout v1.2.0 &&\
#     python setup.py build develop

RUN cd ~/ &&\
    git clone https://github.com/NVIDIA/apex.git &&\
    cd apex &&\
    pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" .

RUN conda install gdal=2.4.2 geopandas fiona rasterio osmnx=0.10 awscli affine pyproj pyhamcrest \
        cython h5py ncurses jupyter ipykernel libgdal matplotlib statsmodels \
        pandas pillow scipy scikit-image scikit-learn shapely \
        rtree testpath tqdm opencv &&\
    conda clean -p &&\
    conda clean -t &&\
    conda clean --yes --all

RUN pip install click easydict utm torchsummary tensorboardX
