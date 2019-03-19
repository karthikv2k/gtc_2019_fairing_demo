FROM pytorch/pytorch:1.0.1-cuda10.0-cudnn7-devel

RUN apt update && apt install wget

# Install google cloud sdk
RUN wget -nv \
    https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz && \
    mkdir /root/tools && \
    tar xvzf google-cloud-sdk.tar.gz -C /root/tools && \
    rm google-cloud-sdk.tar.gz && \
    /root/tools/google-cloud-sdk/install.sh --usage-reporting=false \
        --path-update=false --bash-completion=false \
        --disable-installation-options && \
    rm -rf /root/.config/* && \
    ln -s /root/.config /config && \
    # Remove the backup directory that gcloud creates
    rm -rf /root/tools/google-cloud-sdk/.install/.backup

# Path configuration
ENV PATH $PATH:/root/tools/google-cloud-sdk/bin

# gcloud needs python2
RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda2 && \
     rm ~/miniconda.sh

ENV CLOUDSDK_PYTHON /opt/conda2/bin/python

COPY requirements.txt .
RUN pip install -r requirements.txt

ENV GOOGLE_APPLICATION_CREDENTIALS /root/key.json

COPY . .
RUN cd fairing && pip install .

EXPOSE 8888
CMD jupyter notebook --allow-root  --ip=0.0.0.0 --port=8888
