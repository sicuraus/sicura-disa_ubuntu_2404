# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

**Keep this file free of shipped inventory.** Benchmark revisions, mapped CE counts, and
profile lists drift, and a stale value here is worse than no value because it gets
trusted. Describe structure and point at the command or file that yields the current
answer.

## Commands

```bash
bundle install

bundle exec rake validate lint check rubocop   # static validations, including scelint (what CI runs)
bundle exec rake spec                          # unit tests
bundle exec rake fixtures:clean                # remove spec/fixtures/modules

# Acceptance tests (Vagrant + libvirt; see .github/workflows/ci.yml for the setfile CI uses)
BEAKER_HYPERVISOR=vagrant_libvirt BEAKER_PUPPET_COLLECTION=openvox9 \
  BEAKER_SETFILE='<setfile from ci.yml>' bundle exec rake beaker
```

CI runs the static checks and unit tests on Ruby 3.2 with OpenVox 8 and on Ruby 4.0 with
OpenVox 9 (the matrix comes from `metadata.json` via gha-puppet), and the acceptance tests
against the `openvox9` collection. Without `OPENVOX_GEM_VERSION`, the Gemfile picks the
OpenVox release that matches the running Ruby.

## Architecture

This module contains **no Puppet manifests**. It is a pure data module in the SIMP
Compliance Engine (SCE) format, consumed by the `compliance_engine` module's Hiera
backend. Users set `compliance_engine::enforcement` to a list of profiles and the backend
returns the class parameters the mapped checks call for. Classes are added through
`sicura::classes`, so the `sicura` class (from `sicura-sicura`) is the entry point.

All data lives under `SIMP/compliance_profiles/disa/`:

```
benchmarks/<benchmark>.yaml   # Generated -- do not edit by hand
checks/<module>.yaml          # Hand-authored: Puppet parameter settings (one file per Puppet module)
map-<benchmark>.yaml          # Hand-authored: check ID -> CE IDs, per benchmark
```

```
DISA rule (SCAP XML)  ->  CE  disa:Ubuntu<release>:V-<VulnID>   (benchmarks/)
CE                    ->  profiles disa:mac-{1,2,3}:{classified,sensitive,public}   (benchmarks/)
check                 ->  CE   (map-*.yaml)
check                 ->  Puppet class parameter   (checks/)
```

The benchmark version lives only in each profile's `benchmark_version:` field, so a STIG
release bump leaves unchanged CE names unchanged and existing map entries keep working.

### Check IDs

Check IDs are `disa:ubuntu<release>-<puppet module>:<parameter>[.<detail>]`, for example
`disa:ubuntu2404-chrony:package_ensure`. The release prefix keeps checks from this module
from merging with same-named checks in other compliance data modules (the 22.04 and 24.04
modules, or the Enterprise Linux ones) that may be installed in the same environment.

Only map a check to a CE when the Puppet module it configures supports this Ubuntu
release (check its `metadata.json`), and add that module to `dependencies` in this
module's `metadata.json` and to `.fixtures.yml`.

### Regenerating the benchmark

Benchmark YAML is produced by `components/scripts/convert_benchmark.rb` in the
`sicura-nx` repository from the DISA SCAP XML in `components/source_data/stig/`. The YAML
filename matches the XML source name. From `sicura-nx/components/`:

```bash
BUNDLE_GEMFILE=scripts/Gemfile bundle exec ruby scripts/convert_benchmark.rb \
  -i source_data/stig/<benchmark>.xml \
  -o <this repo>/SIMP/compliance_profiles/disa/benchmarks/<benchmark>.yaml
```

When a new STIG release lands, remove the old benchmark YAML, regenerate, and update the
benchmark list in `README.md`. Map entries for CEs that DISA removed must be dropped.

## Testing

`spec/unit/compliance_profiles_spec.rb` compiles a catalog for every profile on every OS
in `metadata.json`, and asserts that the classes and parameters the profile's Hiera data
calls for are present in the catalog.

`spec/acceptance/init_spec.rb` applies `include sicura` with each profile enforced, checks
idempotence, and checks that the classes the profile calls for are in the applied catalog.
That last check matters: compliance_engine only logs an error for an unknown profile, so
without compliance data the catalog still applies cleanly. The spec reads facts from the
SUT, so profile selection matches the node.

`spec/spec_helper_acceptance.rb` copies `SIMP/` onto the SUT after the fixture modules are
installed. puppet-modulebuilder, which builds the fixture modules, only packages the
standard module directories, so the installed copy of this module has no compliance data
without that step.

`rake beaker` depends on `fixtures:prep` (see `Rakefile`): fixture modules are what get
installed on the SUT.

## Publishing

`.pdkignore` controls what is excluded from the built module. `AGENTS.md` and `CLAUDE.md`
are listed there and are not shipped.
