FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git \
    graphviz \
    htop \
    openssh-client \
    python3-pip \
    vim-nox
RUN pip3 install pip==23.0.1
RUN pip3 install \
    dask==2023.2.1 \
    einops==0.6.0 \
    graphviz==0.20.1 \
    ipython==8.11.0 \
    jax[cuda11_cudnn82]==0.4.4 \
    joblib==1.2.0 \
    jupyterlab==3.6.1 \
    matplotlib==3.7.0 \
    nltk==3.8.1 \
    numba==0.56.4 \
    numpy==1.23.5 \
    pandas==1.5.3 \
    scikit-learn==1.2.1 \
    scipy==1.10.1 \
    seaborn==0.12.2 \
    shap==0.41.0 \
    tensorflow==2.11.0 \
    tensorflow-datasets==4.8.3 \
    tensorflow-probability==0.19.0 \
    xgboost==1.7.4 \
    -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
RUN apt-get install -y curl wget
ENV HOME=/home/jovyan
RUN mkdir -p $HOME
WORKDIR $HOME
CMD jupyter lab --ip 0.0.0.0
EXPOSE 8888
