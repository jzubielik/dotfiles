FROM ubuntu:16.04

RUN apt-get update

RUN apt-get install -y \
      curl \
      make \
      git \
      sudo

WORKDIR /src

CMD ["/bin/bash"]
