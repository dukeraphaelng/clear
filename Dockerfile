FROM crystallang/crystal:0.35.1-alpine
ADD . /src
WORKDIR /src

RUN shards install
RUN crystal lib/ameba/bin/ameba.cr

ENTRYPOINT ["crystal", "spec", "-Dquiet"]