FROM openjdk:14-alpine3.10
MAINTAINER ccx0lw <fcjava@163.com>

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED=1 \
    USER=root \
    HOME=/home/$USER \
    PASSWORD=sha1:d7c0a1595529:921a6a436d60a77e91fdc01cc257b5ee6e9e3477 \
    MEM=2147483648 \
    PORT=8888

USER $USER

RUN BUILD='alpine-sdk linux-headers nodejs npm gcc g++ gfortran make cmake python3-dev freetype-dev musl-dev libpng-dev libxml2-dev libxslt-dev tar make curl build-base wget gnupg perl perl-dev tar zeromq zeromq-dev libffi-dev openssl-dev jpeg-dev zlib-dev' && \
    apk update --no-cache && apk add --no-cache --virtual=build-deps ${BUILD}

# python3
RUN pip3 install -i https://mirrors.aliyun.com/pypi/simple/ pip -U && \
    pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    /usr/bin/python3.7 -m pip install --upgrade pip

# alpine图形
RUN apk add --no-cache fontconfig ttf-dejavu
RUN ln -s /usr/lib/libfontconfig.so.1 /usr/lib/libfontconfig.so && \
    ln -s /lib/libuuid.so.1 /usr/lib/libuuid.so.1 && \
    ln -s /lib/libc.musl-x86_64.so.1 /usr/lib/libc.musl-x86_64.so.1
ENV LD_LIBRARY_PATH /usr/lib

# 安装glibc-2.29
RUN mkdir -p /opt/conda 
RUN apk add --no-cache bash bzip2-dev  --allow-untrusted ca-certificates ;\
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub;\
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk;\
    apk add glibc-2.29-r0.apk

ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV CONTAINER_UID 1000
ENV INSTALLER Miniconda2-latest-Linux-x86_64.sh
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    echo $(wget --quiet -O - https://repo.continuum.io/miniconda/ \
    | grep -A3 $INSTALLER \
    | tail -n1 \
    | cut -d\> -f2 \
    | cut -d\< -f1 ) $INSTALLER  && \
    /bin/bash $INSTALLER -f -b -p $CONDA_DIR && \
    rm $INSTALLER


RUN rm -rf /tmp/* /var/cache/apk/* && rm -rf /root/.cache 

WORKDIR /$USER

EXPOSE $PORT

CMD ["sh"]
