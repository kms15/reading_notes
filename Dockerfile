FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
USER root
# Make sure apt does not pause waiting for user input
ARG DEBIAN_FRONTEND=noninteractive
# Install base debian packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    graphviz \
    htop \
    openssh-client \
    python3-pip \
    r-base \
    r-cran-coda \
    r-cran-devtools \
    r-cran-mvtnorm \
    vim-nox \
    wget
# Update pip to a known-good version
RUN pip3 install pip==23.0.1
# Update pip packages to known-good versions
RUN pip3 install \
    bash_kernel==0.9.0 \
    dask==2023.2.1 \
    einops==0.6.0 \
    graphviz==0.20.1 \
    ipython==8.11.0 \
    jax[cuda11_cudnn82]==0.4.4 \
    joblib==1.2.0 \
    jupyterlab==3.6.3 \
    jupyterlab-git==0.41.0 \
    jupyterlab-link-share==0.3.0 \
    matplotlib==3.7.0 \
    nbdime==3.1.1 \
    nltk==3.8.1 \
    numba==0.56.4 \
    numpy==1.23.5 \
    pandas==1.5.3 \
    pulp==2.7.0 \
    rpy2==3.5.10 \
    scikit-learn==1.2.1 \
    scipy==1.10.1 \
    seaborn==0.12.2 \
    shap==0.41.0 \
    tensorflow==2.11.0 \
    tensorflow-datasets==4.8.3 \
    tensorflow-probability==0.19.0 \
    xgboost==1.7.4 \
    -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
# Install the R kernel for Jupyter and some R packages used by the Statistical
# Rethinking book.
RUN Rscript \
    -e 'install.packages("IRkernel", repos="https://cloud.r-project.org")' \
    -e 'install.packages("dagitty", repos="https://cloud.r-project.org")' \
    -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))' \
    -e 'devtools::install_github("rmcelreath/rethinking@v2.2.1")' \
    -e 'IRkernel::installspec(user=FALSE)'
# Install pytorch
RUN pip3 install \
    torch==2.0.0 \
    torchaudio==2.0.1 \
    torchvision==0.15.1 \
    --index-url https://download.pytorch.org/whl/cu118
# Enable better Jupyter notebook diffs for git
RUN nbdime config-git --enable --system
# Install a bash kernel for git
RUN python3 -m bash_kernel.install
# set up pulp
RUN pulptest
# Turn off python hash randomization to improve reproducibility. Note that the
# randomization exists to prevent denial of service attacks through intentional
# hash collisions, so extra care will be needed if this container is used to
# expose a service to untrusted users (e.g. see the -R option for python).
ENV PYTHONHASHSEED=0
# Tell JAX not to pre-allocate all of the GPU memory (so we can share it
# between different kernels and libraries).
ENV XLA_PYTHON_CLIENT_PREALLOCATE=false
# Tell TensorFlow not to pre-allocate all of the GPU memory (so we can share it
# between different kernels and libraries).
ENV TF_FORCE_GPU_ALLOW_GROWTH=true
# Create a temporary home directory to use
ENV HOME=/home/jovyan
RUN mkdir -p $HOME
WORKDIR $HOME
# Run jupyter lab in collabortive mode, exposing the ports on all interfaces
CMD jupyter lab --ip 0.0.0.0 --collaborative
# Default ports for Jupyter lab and TensorBoard
EXPOSE 8888 6006
