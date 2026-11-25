# Provenance — MariaDB (`12.3.4-CE-ubuntu24.04-r2`)

Every item below is copied from a record in this archive; the record is named in brackets.

## Source

- Upstream repository: https://github.com/MariaDB/server
- Revision built: `mariadb-12.3.4` (commit `e4549ea60c98a8743ed4743d7f92174d8a0005d9`)
- Source tree: `78bf4322f5841e3b499d32898ded3542dd9e6cd52e14f1766c5ca9b5d2f52424` over 27254 files [`docs/provenance/SOURCE_TREE_HASH.json`]
- Community Edition only: enterprise code is removed or refused before the build (CE audit at acquire).

## Build

- Method: `source-rebuild-c`; base image `scratch + a chiselled Ubuntu 24.04 runtime (vendored/chisel/slices.txt, packages.tsv)`
- Compiled with `--network=none` from vendored source, dependencies and base images; BuildKit pinned to `moby/buildkit:v0.31.2` (shipped in `toolchain/`).
- SOURCE_DATE_EPOCH: `1795161102` [`SOURCE_DATE_EPOCH.txt`]
- Frozen inputs: [`docs/provenance/FREEZE_MANIFEST.json`], build recipe: [`docs/provenance/BUILD_RECIPE.json`].

## Output

- Published image: `readystack/mariadb:12.3.4-CE-ubuntu24.04-r2` — index digest `sha256:0785dcb8ea54d54d82216ae102e2d52d4f5d3da7540137b1f2e372f40a864741` [`docs/provenance/LOCKED_DIGEST.txt`]
- linux/amd64 image digest `sha256:ae3fa51b2e0076304d55bfbc251d0420ceb0b016bb46d32a4bde58b5ffe49500` — reproduced from this archive before publishing [`docs/provenance/REPRO_VERIFICATION.json`].

## Attestations and signature

- SBOM + SLSA provenance attached to the image: attached: an SPDX SBOM and SLSA v1 provenance [`docs/provenance/SCOUT_VERDICT.json`]
- cosign signature by the ReadyStack release key: verified before publishing. Check it: `cosign verify --key https://readystack.dev/keys/cosign.pub readystack/mariadb:12.3.4-CE-ubuntu24.04-r2`

## Pinned inputs, and why

- 23 pinned inputs, each with where it came from, why this one, how it was checked and when it was decided: `docs/PINS.md` [`docs/provenance/PINS.json`] (upstream source 2, base and build images 3, image digests 2, dependency versions readystack sets 3, pins in the kit's dockerfiles 5, readystack's build engine 6, dependencies upstream chose 2).

## Build trail

- How this release passed through the ReadyStack harness, record by record (every chain, drive, stage, review round, defect and check, each naming the record it is copied from): `ReadyStack-mariadb-12.3.4-CE-ubuntu24.04-r2.trail.json`, published beside this archive and signed with the release key (`ReadyStack-mariadb-12.3.4-CE-ubuntu24.04-r2.trail.json.sigstore`), and readable at https://readystack.dev/products/mariadb/trail/12.3.4-CE-ubuntu24.04-r2.

