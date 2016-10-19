FROM erlang:19

RUN apt-get update 
#RUN apt-get upgrade -y

RUN apt-get install -y \
    less \
    man \
    python-pip \
    python-virtualenv \
    vim \
    zip

RUN adduser --disabled-login --gecos '' aws
WORKDIR /home/aws

USER aws

RUN \
    mkdir aws && \
    virtualenv aws/env && \
    ./aws/env/bin/pip install awscli && \
    echo 'source $HOME/aws/env/bin/activate' >> .bashrc && \
    echo 'complete -C aws_completer aws' >> .bashrc

RUN git config --global credential.helper '!aws codecommit credential-helper $@'
RUN git config --global credential.UseHttpPath true
RUN git config --global http.sslVerify "false"

COPY build.sh /home/aws/build.sh

CMD ./build.sh -h
