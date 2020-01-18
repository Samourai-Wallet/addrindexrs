FROM    rust:1.37.0-slim

ENV     INDEXER_HOME        /home/indexer
ENV     INDEXER_VERSION     0.1.0
ENV     INDEXER_URL         https://github.com/Samourai-Wallet/addrindexrs.git

RUN     apt-get update && \
        apt-get install -y clang cmake git && \
        apt-get install -y libsnappy-dev

# Create group and user indexer
RUN     addgroup --system -gid 1109 indexer && \
        adduser --system --ingroup indexer -uid 1106 indexer

# Create data directory
RUN     mkdir "$INDEXER_HOME/addrindexrs" && \
        chown -h indexer:indexer "$INDEXER_HOME/addrindexrs"

USER    indexer

# Install addrindexrs
RUN     cd "$INDEXER_HOME" && \
        git clone "$INDEXER_URL" "$INDEXER_HOME/addrindexrs" && \
        cd addrindexrs && \
        git checkout "master"
#        git checkout "tags/v$INDEXER_VERSION"

RUN     cd "$INDEXER_HOME/addrindexrs" && \
        cargo install --path . && \
        cd /usr/local/cargo/bin && \
        sha256sum -b addrindexrs > addrindexrs.asc && \
        cat addrindexrs.asc
        
CMD     tail -f /dev/null

# Manual transfer of files on docker host
# docker cp <container_id>:/usr/local/cargo/bin/addrindexrs /tmp/addrindexrs
# docker cp <container_id>:/usr/local/cargo/bin/addrindexrs.asc /tmp/addrindexrs.asc
