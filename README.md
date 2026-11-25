# MariaDB: ReadyStack build kit

The offline build kit for the Docker image `readystack/mariadb:12.3.4-CE-ubuntu24.04-r2`. It holds what the image is built from (upstream source, base images, toolchain, pinned dependencies) and the documents, so the image can be rebuilt with no network access (`docker build --network=none`).

- Release: [12.3.4-CE-ubuntu24.04-r2](https://github.com/readystack-dev/mariadb/releases/tag/12.3.4-CE-ubuntu24.04-r2)
- Image: [`docker.io/readystack/mariadb:12.3.4-CE-ubuntu24.04-r2`](https://hub.docker.com/r/readystack/mariadb/tags), manifest digest `sha256:ae3fa51b2e0076304d55bfbc251d0420ceb0b016bb46d32a4bde58b5ffe49500`
- Product page: https://readystack.dev/products/mariadb
- Defects: this repository's Issues (defects recorded from 25 November 2026 on) and https://readystack.dev/defects.html?product=mariadb

MariaDB is distributed under its upstream licence (GPL-2.0-only AND LGPL-2.1-or-later); the kit contains upstream's source under that licence, and each vendored component under its own.

## Download

From the [12.3.4-CE-ubuntu24.04-r2 release](https://github.com/readystack-dev/mariadb/releases/tag/12.3.4-CE-ubuntu24.04-r2): `ReadyStack-mariadb-12.3.4-CE-ubuntu24.04-r2.tar.gz` (652.1 MB), SHA-256 `b782cb773ce9b98e25dead9153ab9a008188f361e5008f422e382818e7aeaeb4`.

```sh
sha256sum --check --ignore-missing SHA256SUMS
```

## Verify and rebuild

The rebuild statement is signed with the ReadyStack release key. Check the signature before you rely on it:

```sh
cosign verify-blob --key https://readystack.dev/keys/cosign.pub \
  --bundle ReadyStack-mariadb-12.3.4-CE-ubuntu24.04-r2.rebuild.json.sigstore ReadyStack-mariadb-12.3.4-CE-ubuntu24.04-r2.rebuild.json
```

Unpack with `-p` so file modes are kept, then follow the kit's own README.md and docs/REBUILD.md:

```sh
tar -xpzf ReadyStack-mariadb-12.3.4-CE-ubuntu24.04-r2.tar.gz
cd 12.3.4-CE-ubuntu24.04-r2
less README.md docs/REBUILD.md
```

The build trail (`ReadyStack-mariadb-12.3.4-CE-ubuntu24.04-r2.trail.json`, signed the same way, and its Markdown copy) records how this release was built and checked.

## This repository

`recipe/` holds the kit's recipe files (Dockerfiles, build scripts, pins) as published at https://readystack.dev/products/mariadb/recipe. The complete kit is the release download. Each release is a tag here.
