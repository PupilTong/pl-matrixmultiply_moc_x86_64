# Docker file for matmultiply ChRIS plugin app
#
# Build with
#
#   docker build -t <name> .
#
# For example if building a local version, you could do:
#
#   docker build -t local/pl-MatMultiply .
#
# In the case of a proxy (located at 192.168.13.14:3128), do:
#
#    docker build --build-arg http_proxy=http://192.168.13.14:3128 --build-arg UID=$UID -t local/pl-MatMultiply .
#
# To run an interactive shell inside this container, do:
#
#   docker run -ti --entrypoint /bin/bash local/pl-MatMultiply
#
# To pass an env var HOST_IP to container, do:
#
#   docker run -ti -e HOST_IP=$(ip route | grep -v docker | awk '{if(NF==11) print $9}') --entrypoint /bin/bash local/pl-MatMultiply
#



FROM fnndsc/ubuntu-python3:latest
MAINTAINER fnndsc "dev@babymri.org"

ENV BAZEL_VERSION 0.21.0
WORKDIR /
RUN mkdir /bazel && \
    cd /bazel && \
    wget https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    # curl -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE.txt && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    cd / && \
    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

RUN echo $(g++ --version)
RUN echo $(bazel version)

### TENSORFLOW 
ENV TENSORFLOW_VERSION r1.13
RUN git clone https://github.com/tensorflow/tensorflow.git && \
    cd tensorflow && \
    git checkout ${TENSORFLOW_VERSION}

ENV PYTHON_LIB_PATH /usr/local/lib/python2.7/dist-packages
ENV PYTHONPATH /tensorflow/lib
ENV PYTHON_ARG /tensorflow/lib

ENV APPROOT="/usr/src/matmultiply"
COPY ["matmultiply", "${APPROOT}"]
COPY ["requirements.txt", "${APPROOT}"]

WORKDIR $APPROOT

RUN pip install --upgrade pip
RUN pip install -r requirements.txt


CMD ["matmultiply.py", "--help"]

