FROM docker.io/jupyter/datascience-notebook:latest
USER root
RUN sudo apt update && sudo apt install -y graphviz
RUN pip3 install graphviz
EXPOSE 8888
