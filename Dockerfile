ARG NODE_VERSION=18
ARG VARIANT=trixie

FROM ghcr.io/loong64/node:$NODE_VERSION-$VARIANT

ARG VARIANT

RUN case $VARIANT in \
      "alpine"*) \
        apk add build-base git python3 py3-setuptools --update-cache; \
        ;; \
      *) \
        apt-get update; \
        apt-get install -y git python3-setuptools; \
        apt-get clean; \
        rm -rf /var/lib/apt/lists/*; \
        ;; \
    esac

ARG VERSION
ARG WORKDIR=/usr/src/build

RUN git clone --depth=1 -b ${VERSION} https://github.com/TryGhost/node-sqlite3 ${WORKDIR}

WORKDIR ${WORKDIR}

RUN npm install --ignore-scripts

ENV CFLAGS="${CFLAGS:-} -include ../src/gcc-preinclude.h"
ENV CXXFLAGS="${CXXFLAGS:-} -include ../src/gcc-preinclude.h"
RUN npm run prebuild

RUN if case $VARIANT in "alpine"*) false;; *) true;; esac; then ldd build/**/node_sqlite3.node; nm build/**/node_sqlite3.node | grep \"GLIBC_\" | c++filt || true ; fi

RUN npm run test

CMD ["sh"]