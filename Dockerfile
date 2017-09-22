FROM jupyter/pyspark-notebook


USER root

# RSpark config
ENV R_LIBS_USER $SPARK_HOME/R/lib

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_USER

RUN conda config --add channels conda-forge
# R packages and nlu libraries
RUN conda install --quiet --yes \
    'r-base=3.3.2' \
    'r-irkernel=0.7*' \
    'r-ggplot2=2.2*' \
    'r-sparklyr=0.5*' \
    'networkx=1.11' \
    'biopython=1.70' \
    'unidecode' \
    'leveldb' \
    'spacy'  \
    'tensorflow' \
    'keras' \
    'r-rcurl=1.95*' && conda clean -tipsy
USER root
#download spacy's models for English
RUN python -m spacy download en

USER $NB_USER

# Apache Toree kernel
RUN pip --no-cache-dir install https://dist.apache.org/repos/dist/dev/incubator/toree/0.2.0/snapshots/dev1/toree-pip/toree-0.2.0.dev1.tar.gz
RUN jupyter toree install --sys-prefix

# Spylon-kernel
RUN conda install --quiet --yes 'spylon-kernel=0.4*' && \
    conda clean -tipsy
RUN python -m spylon_kernel install --sys-prefix

RUN rm -r /home/$NB_USER/*
ADD *.* /home/$NB_USER/
ADD Solutions/* /home/$NB_USER/Solutions/
ADD QuickUMLS /home/$NB_USER/QuickUMLS

RUN bash setup_simstring.sh 3

USER root
RUN chown jovyan -R .
RUN pip install leveldb
# RUN pip install unidecode
USER $NB_USER
RUN cp -r simstring/ ~/QuickUMLS/



USER root

COPY pysparknlp-1.0.0.tar.gz /home/jovyan/
COPY demo-data /home/jovyan/demo-data
COPY strata-requirements.txt /home/jovyan/
COPY strata_notebooks/*.ipynb /home/jovyan/
RUN ls -l /home/jovyan
RUN sudo chown -R jovyan:users /home/jovyan
RUN ls -l /home/jovyan

USER $NB_USER

WORKDIR /home/jovyan/

RUN pip install -r strata-requirements.txt
RUN python -m nltk.downloader popular

RUN tar -xzf pysparknlp-1.0.0.tar.gz
#RUN cd demo-data/ && for f in *.tar.gz; do tar -xzf $f; done



#RUN python3 ~/QuickUMLS/install.py ~/QuickUMLS/ ~/QuickUMLS/data

# RUN rm ~QuickUMLS/*.RRF

# docker tag cb9258ec4e02 melcutz/nlu
# docker login --username=melcutz
# docker push melcutz/nlu-demo


# docker build -t nlu-demo:latest .
# docker run -it --rm -p 8888:8888  nlu-demo

# docker images
# docker rmi --force imk
# docker exec --user root -it bdff5651bbc8 bash