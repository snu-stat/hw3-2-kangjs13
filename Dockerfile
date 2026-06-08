FROM rocker/tidyverse:4.4.0

USER root
RUN apt-get update && apt-get install -y \
    wget \
    git \
    imagemagick \
    libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh

ENV PATH=${CONDA_DIR}/bin:${PATH}
RUN conda create -n r-reticulate \
      --override-channels -c conda-forge \
      python=3.10 numpy pandas matplotlib scipy statsmodels scikit-learn -y && \
    conda clean -afy

RUN R -e "install.packages(c('reticulate', 'remotes', 'IRkernel', 'broom', 'MASS'))" && \
    R -e "IRkernel::installspec(user = FALSE)"

ENV RETICULATE_PYTHON=/opt/conda/envs/r-reticulate/bin/python

ENV NB_USER=jovyan
ENV NB_UID=1000
RUN usermod -l ${NB_USER} rstudio && \
    usermod -d /home/${NB_USER} -m ${NB_USER} && \
    chown -R ${NB_USER} /opt/conda /home/${NB_USER}

COPY _site/hw03.ipynb /home/${NB_USER}/hw03.ipynb
RUN chown ${NB_USER}:users /home/${NB_USER}/hw03.ipynb

USER ${NB_USER}
WORKDIR /home/${NB_USER}

EXPOSE 8888
