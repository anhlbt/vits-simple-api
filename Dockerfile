FROM python:3.10.11-slim-bullseye

RUN mkdir -p /app
WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

COPY . /app

RUN apt-get update && \
    apt-get install -yq build-essential espeak-ng cmake wget && \
    apt-get clean && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip --no-cache-dir && \
    pip install MarkupSafe==2.1.2 numpy==1.23.3 cython six==1.16.0 safetensors==0.3.2 --no-cache-dir

RUN wget https://raw.githubusercontent.com/Artrajz/archived/main/openjtalk/openjtalk-0.3.0.dev2.tar.gz && \
    tar -zxvf openjtalk-0.3.0.dev2.tar.gz && \
    cd openjtalk-0.3.0.dev2 && \
    rm -rf ./pyopenjtalk/open_jtalk_dic_utf_8-1.11 && \
    python setup.py install && \
    cd ../ && \
    rm -f openjtalk-0.3.0.dev2.tar.gz && \
    rm -rf openjtalk-0.3.0.dev2

RUN pip install torch --index-url https://download.pytorch.org/whl/cpu --no-cache-dir

RUN pip install -r requirements.txt --no-cache-dir

RUN cd bert_vits2/monotonic_align && \
    mkdir monotonic_align && \
    python setup.py build_ext --inplace && \
    cd /app

RUN pip install gunicorn --no-cache-dir



EXPOSE 23456

CMD ["gunicorn", "-c", "gunicorn_config.py", "app:app"]