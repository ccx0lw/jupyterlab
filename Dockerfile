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

RUN BUILD='alpine-sdk linux-headers nodejs npm gcc g++ gfortran make cmake python3-dev freetype-dev musl-dev libpng-dev libxml2-dev libxslt-dev tar make curl build-base wget gnupg perl perl-dev tar zeromq zeromq-dev' && \
    apk update --no-cache && apk add --no-cache --virtual=build-deps ${BUILD}

RUN pip3 install -i https://mirrors.aliyun.com/pypi/simple/ pip -U && \
    pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    /usr/bin/python3.7 -m pip install --upgrade pip

COPY requirements.txt .
RUN ([ -f requirements.txt ] && \
      pip3 install --no-cache-dir -r requirements.txt)

# perl
RUN curl -sL http://cpanmin.us | perl - App::cpanminus
RUN export ARCHFLAGS='-arch x86_64' && \
    cpanm -n --mirror http://mirrors.163.com/cpan --mirror-only --build-args 'OTHERLDFLAGS=' ZMQ::LibZMQ3 Devel::IPerl PDL Moose MooseX::AbstractFactory MooseX::AbstractMethod MooseX::Storage Test::More

RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip

RUN mkdir ijava-kernel && \
    unzip ijava-kernel.zip -d ijava-kernel && \
    cd ijava-kernel && \
    python3 install.py --sys-prefix

RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    jupyter serverextension enable --py jupyterlab && \
    jupyter serverextension enable --py nbresuse --sys-prefix && \
    jupyter nbextension enable --py nbresuse --sys-prefix && \
    jupyter serverextension enable elyra && \
    jupyter labextension install jupyterlab-drawio @krassowski/jupyterlab-lsp jupyterlab-topbar-extension jupyterlab-system-monitor jupyterlab-logout jupyterlab-theme-toggle @jupyterlab/toc @elyra/pipeline-editor-extension @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension update --all

RUN jupyter lab build --dev-build=False --minimize=True

# alpine图形
RUN apk add --no-cache fontconfig ttf-dejavu
RUN ln -s /usr/lib/libfontconfig.so.1 /usr/lib/libfontconfig.so && \
    ln -s /lib/libuuid.so.1 /usr/lib/libuuid.so.1 && \
    ln -s /lib/libc.musl-x86_64.so.1 /usr/lib/libc.musl-x86_64.so.1
ENV LD_LIBRARY_PATH /usr/lib

RUN rm -rf /tmp/* /var/cache/apk/* && rm -rf /root/.cache && rm -rf ijava-kernel.zip

WORKDIR /$USER

COPY . .

EXPOSE $PORT

CMD ["sh", "-c", "sed -i \"s/#c.NotebookApp.password =.*/c.NotebookApp.password = '${PASSWORD}'/g\" jupyter_notebook_config.py && nohup iperl && jupyter lab --ip=0.0.0.0 --port=$PORT --config=jupyter_notebook_config.py --notebook-dir=/root --allow-root --NotebookApp.ResourceUseDisplay.track_cpu_percent=True --NotebookApp.ResourceUseDisplay.mem_limit=$MEM"]
