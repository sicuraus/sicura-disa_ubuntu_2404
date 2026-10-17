# sicura-disa_ubuntu_2404

Compliance Engine data for Ubuntu 24.04 LTS DISA STIG benchmarks.

The following DISA STIG benchmarks are currently supported:

* Canonical Ubuntu 24.04 LTS V1R3 - SCAP

This module is in early development. Every rule in the benchmark is available
for reporting, but only a small number of rules are mapped to Puppet settings
for enforcement so far. See
`SIMP/compliance_profiles/disa/map-*.yaml` for the rules that are currently
enforced.

## Enabling DISA STIG enforcement

Classes are added through `sicura::classes`, so include the `sicura` class
(from [sicura-sicura](https://github.com/sicuraus/sicura-sicura)) on the
nodes where you are enforcing a compliance profile:

```puppet
include sicura
```

In your environment-level `hiera.yaml`, add a layer for `compliance_engine::enforcement`.

```yaml
hierarchy:
  - name: Compliance Engine
    lookup_key: compliance_engine::enforcement
```

At a Hiera layer that applies to the nodes where you are enforcing the
compliance profile, add a `compliance_engine::enforcement` array. For
example, to enforce `disa:mac-1:classified`, use the following:

```yaml
compliance_engine::enforcement:
  - disa:mac-1:classified
```

The following compliance profiles are available:

* `disa:mac-1:classified`
* `disa:mac-1:public`
* `disa:mac-1:sensitive`
* `disa:mac-2:classified`
* `disa:mac-2:public`
* `disa:mac-2:sensitive`
* `disa:mac-3:classified`
* `disa:mac-3:public`
* `disa:mac-3:sensitive`

## User Required Activities

There are a few items that the user must configure since there is no method
for automatically determining the appropriate values.

### Time Sources

Enforcement installs and configures `chrony` with the defaults from the
[puppet-chrony](https://github.com/voxpupuli/puppet-chrony) module. DISA STIG
requires synchronizing with an authoritative time source, so set the servers
or pools for your site via Hiera:

```yaml
chrony::servers:
  - time.example.com
```
