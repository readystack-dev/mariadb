# GENERATED L-009 hermetic C build (--network=none, SBOM+SLSA-attestation-producing).
# Pinned bases; vendored source (in-tree deps) + extra build debs + runtime debs from Dockerfile.vendor.
FROM ubuntu:24.04@sha256:9c7f200c07e3d4a03e7249d2c16bf66a51120fb876aa2242cf31451412543289 AS cbuild
# dpkg-install the vendored EXTRA build debs (pkg-config/libssl-dev/...) — gcc/make are in the builder.
RUN --mount=type=bind,source=vendored/build-debs,target=/tmp/bdebs \
    set --; for f in /tmp/bdebs/*.deb; do [ -e "$f" ] && set -- "$@" "$f"; done; \
    for pass in 1 2 3 4 5; do [ $# -eq 0 ] || dpkg -i --skip-same-version "$@" >/dev/null 2>&1 && break; done; \
    dpkg --configure -a && bad= && for d in "$@"; do p=$(dpkg-deb -f "$d" Package) v=$(dpkg-deb -f "$d" Version); \
      case "$(dpkg-query -W -f='${Version} ${db:Status-Abbrev}' "$p" 2>/dev/null)" in "$v ii"*) ;; *) bad="$bad $p=$v" ;; esac; done && \
    { [ -z "$bad" ] || { echo "vendored debs not installed at their vendored version:$bad" >&2; false; }; }
WORKDIR /src
COPY vendored/mariadb-src/ .
ARG SOURCE_DATE_EPOCH=1795161102
ENV SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH}
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb -DINSTALL_LAYOUT=STANDALONE '-DCOMPILATION_COMMENT=ReadyStack build of MariaDB Server' -DSOURCE_REVISION=e4549ea60c98a8743ed4743d7f92174d8a0005d9 -DUPDATE_SUBMODULES=OFF -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_PCRE=system -DWITH_LIBFMT=system -DWITH_LIBAIO=ON -DWITH_URING=OFF -DWITH_JEMALLOC=no -DWITH_NUMA=OFF -DWITH_SYSTEMD=no -DWITH_WSREP=OFF -DWITH_UNIT_TESTS=OFF -DWITH_EMBEDDED_SERVER=OFF -DWITH_SBOM=OFF -DINSTALL_MYSQLTESTDIR= -DINSTALL_SQLBENCHDIR= -DPLUGIN_AUTH_SOCKET=STATIC -DPLUGIN_ROCKSDB=NO -DPLUGIN_COLUMNSTORE=NO -DPLUGIN_DUCKDB=NO -DPLUGIN_S3=NO -DPLUGIN_MROONGA=NO -DPLUGIN_SPIDER=NO -DPLUGIN_CONNECT=NO -DPLUGIN_OQGRAPH=NO -DPLUGIN_SPHINX=NO -DPLUGIN_VIDEX=NO -DPLUGIN_AUTH_PAM=NO -DPLUGIN_AUTH_PAM_V1=NO -DPLUGIN_AUTH_GSSAPI=NO -DPLUGIN_AUTH_GSSAPI_CLIENT=NO -DPLUGIN_HASHICORP_KEY_MANAGEMENT=NO -DPLUGIN_AWS_KEY_MANAGEMENT=NO -DPLUGIN_CRACKLIB_PASSWORD_CHECK=NO -DPLUGIN_PROVIDER_BZIP2=NO -DPLUGIN_PROVIDER_LZMA=NO -DPLUGIN_PROVIDER_LZO=NO -DPLUGIN_PROVIDER_SNAPPY=NO -DPLUGIN_PROVIDER_LZ4=NO -DPLUGIN_HANDLERSOCKET=NO -DPLUGIN_AUDIT_NULL=NO -DPLUGIN_AUTH_0X0100=NO -DPLUGIN_AUTH_TEST_PLUGIN=NO -DPLUGIN_DAEMON_EXAMPLE=NO -DPLUGIN_DEBUG_KEY_MANAGEMENT=NO -DPLUGIN_DIALOG_EXAMPLES=NO -DPLUGIN_EXAMPLE=NO -DPLUGIN_EXAMPLE_KEY_MANAGEMENT=NO -DPLUGIN_FTEXAMPLE=NO -DPLUGIN_FUNC_TEST=NO -DPLUGIN_QA_AUTH_CLIENT=NO -DPLUGIN_QA_AUTH_INTERFACE=NO -DPLUGIN_QA_AUTH_SERVER=NO -DPLUGIN_TEST_SQL_DISCOVERY=NO -DPLUGIN_TEST_SQL_SERVICE=NO -DPLUGIN_TEST_VERSIONING=NO -DPLUGIN_TYPE_TEST=NO
RUN J=$(nproc); M=$(awk '/MemAvailable/ {print int($2/2097152)}' /proc/meminfo); [ "$M" -ge 1 ] || M=1; [ "$M" -lt "$J" ] && J=$M; echo "compiling with $J parallel jobs"; cmake --build build --parallel "$J"
RUN cmake --install build --strip
RUN cmake --install build --component Test --prefix /tmp/test-component && (cd /tmp/test-component && find . \( -type f -o -type l \) -print0) | (cd /usr/local/mariadb && xargs -0 -r rm -f) && rm -rf /tmp/test-component
RUN rm -f /usr/local/mariadb/bin/mysql && printf '#!/bin/sh\nexec /usr/local/mariadb/bin/mariadb "$@"\n' > /usr/local/mariadb/bin/mysql && chmod 0755 /usr/local/mariadb/bin/mysql
RUN set -eu; find /usr/local/mariadb -type f | LC_ALL=C sort | while read -r f; do \
      readelf -h "$f" >/dev/null 2>&1 || continue; \
      readelf -lW "$f" | sed -n 's/.*Requesting program interpreter: \(.*\)]$/\1/p'; \
      readelf -dW "$f" | sed -n 's/.*Shared library: \[\(.*\)\]$/\1/p'; \
    done | LC_ALL=C sort -u | while read -r lib; do case "$lib" in \
      /*) echo "$lib" ;; *) [ -n "$(find /usr/local/mariadb -name "$lib" -print -quit)" ] || echo "$lib" ;; esac; \
    done > /kitforge.needs && echo "the install prefix loads: $(tr '\n' ' ' < /kitforge.needs)"
# rs-probe: the HEALTHCHECK helper (standard library only, from the kit's rs-probe.go)
FROM golang:1.27.3-bookworm@sha256:972b4110ba0f47539a975c31e52c64765e1ff19f2d74469ae4a595c6676e80a5 AS build_rs_probe
WORKDIR /probe
COPY rs-probe.go main.go
COPY rs-probe.mod go.mod
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOFLAGS="-buildvcs=false" GOPROXY=off SOURCE_DATE_EPOCH=1795161102
RUN go build -trimpath -ldflags='-s -w' -o /rs-probe .
# the chiselled rootfs (vendored/chisel, cut by Dockerfile.vendor), the service user, the binaries
FROM ubuntu:24.04@sha256:9c7f200c07e3d4a03e7249d2c16bf66a51120fb876aa2242cf31451412543289 AS rootfs
ARG SOURCE_DATE_EPOCH=1795161102
ADD vendored/chisel/rootfs.tar /rootfs/
RUN printf 'mysql:x:999:999::/home/mysql:/bin/sh\n' >> /rootfs/etc/passwd && printf 'mysql:x:999:\n' >> /rootfs/etc/group && \
    mkdir -p /rootfs/home/mysql /rootfs/var/lib/mysql /rootfs/run/mysqld /rootfs/var/lib/mysql-files /rootfs/docker-entrypoint-initdb.d && chown -R 999:999 /rootfs/home/mysql /rootfs/var/lib/mysql /rootfs/run/mysqld /rootfs/var/lib/mysql-files /rootfs/docker-entrypoint-initdb.d
COPY --from=build_rs_probe /rs-probe /rootfs/usr/local/bin/rs-probe
COPY my.cnf /rootfs/etc/mysql/my.cnf
COPY docker-entrypoint.sh /rootfs/usr/local/bin/docker-entrypoint.sh
COPY --from=cbuild /usr/local/mariadb /rootfs/usr/local/mariadb
COPY --from=cbuild /kitforge.needs /tmp/needs/mariadb
RUN chmod 755 /rootfs/usr/local/bin/rs-probe && \
    chmod 0755 /rootfs/usr/local/bin/docker-entrypoint.sh
RUN set -eu; ROOT=/rootfs; \
    mkdir -p "$ROOT/etc/mysql/conf.d"
RUN --mount=type=bind,source=vendored/chisel,target=/chisel set -eu; \
    for n in /tmp/needs/*; do while read -r lib; do [ -n "$lib" ] || continue; \
      case "$lib" in /*) [ -e "/rootfs$lib" ] ;; *) [ -n "$(find /rootfs/usr/lib /rootfs/usr/lib64 -name "$lib" 2>/dev/null | head -1)" ] ;; esac || \
      { echo "$(basename "$n") needs $lib, which the chiselled rootfs does not have: add its slice to runtime_base.slices" >&2; exit 1; }; \
    done < "$n"; done; rm -rf /tmp/needs; \
    [ -e /rootfs/etc/os-release ] || { echo "no /etc/os-release: base-files_release-info is missing" >&2; exit 1; }; \
    [ "$(grep -c '^Package: ' /rootfs/var/lib/dpkg/status)" = "$(wc -l < /chisel/packages.tsv)" ] || \
      { echo "/var/lib/dpkg/status does not list every package of vendored/chisel/packages.tsv" >&2; exit 1; }; \
    rm -rf /rootfs/var/log/dpkg.log /rootfs/var/log/alternatives.log /rootfs/var/log/apt /rootfs/var/cache/ldconfig/aux-cache /rootfs/var/cache/fontconfig
FROM scratch
ARG SOURCE_DATE_EPOCH=1795161102
COPY --from=rootfs /rootfs/ /
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin PATH=/usr/local/mariadb/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin LANG=C.UTF-8
LABEL org.opencontainers.image.title="MariaDB"
LABEL org.opencontainers.image.version="12.3.4-CE-ubuntu24.04-r2"
LABEL org.opencontainers.image.source="https://github.com/MariaDB/server"
LABEL org.opencontainers.image.description="MariaDB Server 12.3.4 (12.3 LTS) compiled from source (CE, non-root, offline-rebuildable)"
LABEL org.opencontainers.image.licenses="GPL-2.0-only AND LGPL-2.1-or-later"
LABEL org.opencontainers.image.revision="e4549ea60c98a8743ed4743d7f92174d8a0005d9"
HEALTHCHECK --interval=5s --timeout=180s --start-period=60s \
  CMD test ! -e /var/lib/mysql/.readystack-init-incomplete && mariadb-admin --protocol=socket --user=mysql --silent ping || exit 1
USER mysql
EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
