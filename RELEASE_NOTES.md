# MariaDB 12.3.4 — ReadyStack release `12.3.4-CE-ubuntu24.04-r2`

Generated 2026-11-20 from this release's build records and strategy. Statements that come from a single record name it in brackets; the others come from this release's strategy and build log.

## Release

- **Image:** `readystack/mariadb:12.3.4-CE-ubuntu24.04-r2` (linux/amd64). Index digest `sha256:0785dcb8ea54d54d82216ae102e2d52d4f5d3da7540137b1f2e372f40a864741` [`docs/provenance/LOCKED_DIGEST.txt`].
- **Image manifest digest:** `sha256:ae3fa51b2e0076304d55bfbc251d0420ceb0b016bb46d32a4bde58b5ffe49500` [`TARGET_DIGEST.txt`].
- **Upstream:** MariaDB 12.3.4 built from source at `mariadb-12.3.4` of https://github.com/MariaDB/server — upstream notes: https://github.com/MariaDB/server/releases/tag/mariadb-12.3.4 [`docs/provenance/BUILD_RECIPE.json`].
- **Base image:** none (`FROM scratch`): a chiselled Ubuntu 24.04 runtime, the files Canonical's chisel cut from Ubuntu's own packages (`vendored/chisel/slices.txt`, `vendored/chisel/packages.tsv`); runtime user `mysql`.
- **Build:** `source-rebuild-c`, compiled offline with `--network=none`.
- **Supersedes:** ReadyStack release `12.3.4-CE-ubuntu24.04-r1`.

## What changed in this release

- Upstream version unchanged (12.3.4); ReadyStack rebuild.
- MariaDB 12.3.4 is unchanged from the release this supersedes (12.3.4-CE-ubuntu24.04-r1); this release rebuilds it. Changes: the image is rebuilt on the current ubuntu:24.04 image (sha256:9c7f200c07e3…), which its maintainers updated after 12.3.4-CE-ubuntu24.04-r1 was built on sha256:2198e4c65076…. Settings, ports and data volumes are those of 12.3.4-CE-ubuntu24.04-r1: replace the container with this image on the same volumes.

## Security status at release (measured 2026-11-20)

- **Docker Scout:** 0 fixable critical/high vulnerabilities; runs as `mysql` (non-root); SBOM + provenance attestations present (SPDX SBOM + SLSA v1) [`docs/provenance/SCOUT_VERDICT.json`].
- **OSV cross-check:** no fixable critical/high vulnerability beyond Docker Scout's findings.
- **Signature:** cosign signature verified by ReadyStack's release gate before publishing; check it yourself with `cosign verify --key https://readystack.dev/keys/cosign.pub readystack/mariadb:12.3.4-CE-ubuntu24.04-r2` (signatures are recorded in the public Sigstore transparency log).
- **ReadyStack release check at release:** passed (ReadyStack's own test, not a Docker Scout grade). Vulnerabilities are disclosed every day and the image never changes, so it is re-checked daily, beside Docker Scout's own dated grade, at https://readystack.dev/queue.
- **Before exposing this service:** MARIADB_ROOT_HOST defaults to %, so root can log in over the network with its password; set MARIADB_ROOT_HOST=localhost on the first start to create no network root account, or restrict it to an address or to a subnet written as address/netmask, such as 192.168.1.0/255.255.255.0 (CIDR such as 192.168.1.0/24 is accepted but never matches).
- **Before exposing this service:** With no certificate configured the server makes a new self-signed TLS certificate at every start; clients that verify certificates need your own, configured with ssl_cert and ssl_key in a file under /etc/mysql/conf.d/.
- **Before exposing this service:** Keep port 3306 on a private network: it accepts password logins for every account with a network host.

## Reproducibility

Rebuilds offline from this archive to the identical image digest `sha256:ae3fa51b2e0076304d55bfbc251d0420ceb0b016bb46d32a4bde58b5ffe49500`: run `./BUILD_OFFLINE.sh`, then `./VERIFY_OFFLINE.sh` (add `--online` to confirm the Docker Hub tag holds the same digest). Before publishing, ReadyStack rebuilt the kit with `./BUILD_OFFLINE.sh` and compared the result with the published digest [`docs/provenance/REPRO_VERIFICATION.json`], then ran `./BUILD_OFFLINE.sh` and `./VERIFY_OFFLINE.sh` from this archive (without `--online`).

## Validation

- 13 of 13 use cases passed (13 authored) against the running image [`docs/validation/test-results.json`].

## Known issues

- **medium** (ReadyStack package): The seed-data record says the product has no SQL database ('config/CRD-native product') [`RSD-mariadb-8fa1934de3`] (carried from `12.3.3-CE-ubuntu24.04-r1`, recorded there as `RSD-mariadb-5310867f4f`)
- **medium** (upstream): MariaDB accepts an account host written in CIDR form (192.168.1.0/24) but it never matches (https://jira.mariadb.org/browse/MDEV-25515) [`RSD-mariadb-8d152d1f1d`] (carried from `12.3.3-CE-ubuntu24.04-r1`, recorded there as `RSD-mariadb-f6d5c77fa9`)

## Verify this archive

```
sha256sum -c CHECKSUMS.sha256
./BUILD_OFFLINE.sh && ./VERIFY_OFFLINE.sh --online
cosign verify --key https://readystack.dev/keys/cosign.pub readystack/mariadb:12.3.4-CE-ubuntu24.04-r2
```

ReadyStack records every signature in the public Sigstore transparency log (Rekor), so the command needs no extra flags.

