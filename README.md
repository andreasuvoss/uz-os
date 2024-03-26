# uz-os

## Building the image locally for testing purposes
It can be annoying to be required to run a GitHub action in order to test if the build is successful when extending the
image. You can install [the blue-build CLI](https://github.com/blue-build/cli) on your machine and run the following command

```bash
bluebuild template -o Containerfile ./config/recipe.yml && podman build . -t uz-os
```

Once the image has been built, you can push it to a private registry. In my case I spun up a registry locally using
docker `docker run -d -p 5000:5000 --restart always --name registry registry:2`. In this case I had to add a file to the
`/etc/containers/registries.conf.d` directory to allow for insecure connections. The file is called `localhost.conf` and
looks like this

```
[[registry]]
location = "localhost:5000"
insecure = true
```

we can now push the image to the local registry

```bash
podman push localhost/uz-os:latest localhost:5000/anvo/uz-os:latest
```

I spun up a VM in order to rebase my image onto the default Silverblue image, when rebasing from a local registry from
within a VM, I had to also add an unsecure registry like earlier, however the location is not localhost, but the IP you
get when running the `ip route | grep default` command. In my case i got the IP `192.168.124.1` so my `.conf` inside the
VM looked like this

```
[[registry]]
location = "192.168.124.1:5000"
insecure = true
```

once that file is in place, I can rebase from my local registry

```bash
rpm-ostree rebase ostree-unverified-registry:192.168.124.1:5000/anvo/uz-os:latest -r
```

## Installation

> **Warning**  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```bash
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/andreasuvoss/silverblue-voss:latest
  ```
- Reboot to complete the rebase:
  ```bash
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```bash
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/andreasuvoss/silverblue-voss:latest
  ```
- Reboot again to complete the installation
  ```bash
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

### GNOME extensions
Not all GNOME extensions can be installed automatically here is a list of some potential useful ones.

* https://extensions.gnome.org/extension/1460/vitals/
* https://extensions.gnome.org/extension/3843/just-perfection/
* https://extensions.gnome.org/extension/28/gtile/
* https://extensions.gnome.org/extension/1873/disable-unredirect-fullscreen-windows/

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/blue-build/legacy-template
```
