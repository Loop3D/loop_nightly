FROM continuumio/miniconda3
LABEL maintainer="lachlan.grose@monash.edu"

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    gcc \
    g++ \
    libc-dev
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}

USER root
RUN chown -R ${NB_UID} ${HOME}

RUN conda install cython scikit-build numpy python=3.7 -y
RUN git clone https://github.com/Loop3D/LoopStructural
WORKDIR "./LoopStructural"
RUN pip install .    

WORKDIR ${HOME}
RUN git clone https://github.com/Loop3D/map2loop-2.git
WORKDIR "./map2loop-2"
RUN git submodule update --init --recursive
RUN pip install -e .

WORKDIR ${HOME}
RUN git clone https://github.com/Loop3d/surfe
WORKDIR "./surfe"
RUN git submodule update --init --recursive
RUN python setup.py install 


RUN conda install -c conda-forge pip scikit-learn cython numpy==1.20.1 pandas scipy pymc3 jupyter pyamg -y
RUN conda install -c conda-forge ipywidgets
RUN conda install -c conda-forge ipyleaflet
RUN conda install -c conda-forge folium
RUN pip install ipyfilechooser
RUN jupyter nbextension enable --py --sys-prefix ipyleaflet
RUN pip install lavavu-osmesa

# ENV NB_USER jovyan
# ENV NB_UID 1000
# ENV HOME /home/${NB_USER}

# RUN adduser --disabled-password \
#     --gecos "Default user" \
#     --uid ${NB_UID} \
#     ${NB_USER}
WORKDIR ${HOME}

USER root
# RUN chown -R ${NB_UID} ${HOME}



RUN conda install -c conda-forge jupyterlab nodejs -y
RUN pip install snakeviz

# Add Tini
# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

WORKDIR "./notebooks"

USER ${NB_USER}

CMD ["jupyter", "notebook", "--ip='0.0.0.0'", "--NotebookApp.token=''", "--no-browser" ]
EXPOSE 8888