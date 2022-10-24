FROM docker.io/jupyter/datascience-notebook:2022-10-24
USER root
RUN sudo apt update && sudo apt install -y graphviz
RUN pip3 install pip==22.3
RUN pip3 install graphviz==0.20.1 scikit-learn==1.1.2 jax[cpu]==0.3.23 \
    einops==0.5.0 tensorflow==2.10.0 tensorflow-probability==0.18.0 \
    torch==1.12.1 torchvision==0.13.1 torchaudio==0.12.1 xgboost==1.6.2 \
    ipython==8.5.0
EXPOSE 8888
