FROM condaforge/linux-anvil-comp7
RUN sudo -n yum install -y openssh-clients && \
    sudo -n yum clean all && \
    sudo -n rm -rf /var/cache/yum/*
RUN mkdir -p /tmp/repo/bioconda_utils/
COPY ./bioconda_utils/bioconda_utils-requirements.txt /tmp/repo/bioconda_utils/
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --set auto_update_conda False
RUN export PATH="/opt/conda/bin:${PATH}" && \
    : 'Make sure we get the (working) conda we want before installing the rest.' && \
    sed -nE \
        -e 's/\s*#.*$//' \
        -e 's/^(conda([><!=~ ].+)?)$/\1/p' \
        /tmp/repo/bioconda_utils/bioconda_utils-requirements.txt \
        | xargs -r conda install -y
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda install -y --file /tmp/repo/bioconda_utils/bioconda_utils-requirements.txt
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda clean -y -it
COPY . /tmp/repo
RUN export PATH="/opt/conda/bin:${PATH}" && \
    pip install /tmp/repo
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/tmp/repo/docker-entrypoint" ]
