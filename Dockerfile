FROM ubuntu:24.10

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

# General requirements not in the base image
RUN apt-get -qqy update \
  && apt-get -qqy install \
    ca-certificates \
    git \
    locales \
    make \
    opam \
    python3 \
    tzdata \
    sudo

# Ensure a `python` binary exists
RUN apt-get -qqy update \
    && apt-get install -qqy python-is-python3

RUN apt-get -y autoremove

ENV TZ "UTC"
RUN echo "${TZ}" > /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN useradd test \
         --shell /bin/bash  \
         --create-home \
    && usermod -a -G sudo test \
    && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && echo 'test:secret' | chpasswd

USER test

WORKDIR /home/test

# Remove information on how to use sudo on login
RUN sudo echo ""

# RUN mkdir -p /home/test/spec
# RUN mkdir -p /home/spec

# VOLUME /home/pastithas/src/wasm-spec
# COPY --chown=test /home/spec /home/test/spec
# WORKDIR /home/test/

RUN opam init --disable-sandboxing
RUN opam install dune
RUN opam install menhir -y
# ENV PATH="/home/test/.opam/default/bin:${PATH}"

RUN eval $(opam env)
# RUN /home/spec/test/build.py --js /tmp/foo
