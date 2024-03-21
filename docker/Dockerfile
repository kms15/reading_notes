FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
USER root
# Make sure apt does not pause waiting for user input
ARG DEBIAN_FRONTEND=noninteractive
# Install base debian packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    graphviz \
    htop \
    openssh-client \
    python3-pip \
    r-base \
    r-base-dev \
    r-cran-arm \
    r-cran-bayesplot \
    r-cran-coda \
    r-cran-devtools \
    r-cran-ggplot2 \
    r-cran-knitr \
    r-cran-loo \
    r-cran-mvtnorm \
    r-cran-rprojroot \
    r-cran-rstan \
    r-cran-rstanarm \
    r-cran-survey \
    vim-nox \
    wget
# Update pip to a known-good version
RUN pip3 install pip==23.3.1
# Update pip packages to known-good versions
RUN pip3 install \
    bash_kernel==0.9.3 \
    dask==2023.12.0 \
    einops==0.7.0 \
    graphviz==0.20.1 \
    ipython==8.18.1 \
    joblib==1.3.2 \
    "jax[cuda11_local]<=0.4.22" \
    jupyterlab==4.0.9 \
    jupyterlab-git==0.50.0 \
    lightgbm==4.1.0 \
    matplotlib==3.8.2 \
    nbdime==4.0.1 \
    nltk==3.8.1 \
    numba==0.58.1 \
    numpy==1.24.2 \
    pandas==2.1.4 \
    patsy==0.5.4 \
    pulp==2.7.0 \
    pymc==5.10.2 \
    ray==2.8.1 \
    rpy2==3.5.14 \
    scikit-learn==1.3.2 \
    scipy==1.11.4 \
    seaborn==0.13.0 \
    shap==0.44.0 \
    statsmodels==0.14.0 \
    tensorflow==2.13.0 \
    tensorflow-datasets==4.9.3 \
    tensorflow-probability==0.21.0 \
    xgboost==2.0.2 \
    -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
# HACK: we can install the latest version of keras despite tensorflow
# requesting an older version as long as we do so after tensorflow is already
# installed.
RUN pip3 install keras==3.0.5
## Install the R kernel for Jupyter and some R packages used by the Statistical
## Rethinking book.
RUN Rscript \
    -e 'install.packages("IRkernel", repos="https://cloud.r-project.org")' \
    -e 'install.packages("dagitty", repos="https://cloud.r-project.org")' \
    -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))' \
    -e 'devtools::install_github("rmcelreath/rethinking@v2.2.1")' \
    -e 'IRkernel::installspec(user=FALSE)'
## Install pytorch
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
CMD jupyter lab --ip 0.0.0.0
# Default ports for Jupyter lab and TensorBoard
EXPOSE 8888 6006
