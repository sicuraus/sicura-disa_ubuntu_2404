# sicura-disa_ubuntu_2404

Compliance Engine data for Ubuntu 24.04 LTS DISA STIG benchmarks.

## Enabling DISA STIG enforcement

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
