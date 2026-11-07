# Omeka S Docker Template

Docker Compose deployment of [Omeka S](https://omeka.org/s/) with Traefik and the Lehigh LTS application image. The local development override provides MariaDB and Mailpit.

## Requirements

Docker with Compose v2, Bash, and Make.

## Quick start

For local development, copy `compose.override-example.yaml` to `compose.override.yaml`, then run:

```bash
make up
make healthcheck
```

The site is available at `http://localhost/`. `make init` generates secrets without replacing existing values. Run `make test` for a fresh-site smoke test, `make lint` for static checks, and `make clean` to remove local volumes after confirmation.

For production, configure the external database as described below before running `make up`. Place a trusted certificate covering `omeka-s-vm.cc.lehigh.edu` and its private key in `certs/tls.crt` and `certs/tls.key`, and set `BACKEND_TLS_ENABLED=true` in `.env`. Set `INGRESS_HOSTNAMES` to the public application hostname and `INGRESS_SCHEME=https`. The VM listens on port 443; restrict access to the central frontend. The local override publishes HTTP port 80 for development.

## Upgrades

Back up the database, files volume, configuration, and secrets before changing the application image in `Dockerfile`. Rebuild the image and keep public traffic stopped while checking whether the release requires a browser migration. Complete any required migration through a private connection before restoring traffic. Verify the site and extensions after the upgrade.

## Template notes

- `traefik` is the only published ingress.
- `omeka-s` is a small downstream customization image based on the app-versioned Lehigh LTS Omeka S image.
- `mariadb` stores application data when using the local development override.
- `omeka-s-files` persists uploaded files.
- Secrets are generated into `./secrets/`.
- Rollout and verification programs are versioned with the site and mounted read-only into `omeka-s`.

Application core and its Composer dependencies belong to the base image. Downstream code belongs under `modules/` and `themes/`; do not copy or bind-mount the complete Omeka S application tree over the image.

Rebuild and redeploy the derived site image after changing a checked-in module or theme. These directories are intentionally not bind-mounted over the base image because doing so would hide modules and themes shipped by Omeka S.

In the local development override, MariaDB and the one-shot `database-init` service receive `DB_ROOT_PASSWORD`. The initializer creates the database and scoped user; the app receives only `OMEKA_S_DB_PASSWORD` as `DB_PASSWORD`.

### Production with external MySQL or Galera

Use `compose.yaml` without the local override. Provision the database and application account on Galera, allow connections from the Docker host's outbound address, and set the connection in `.env`:

```dotenv
DB_HOST=mysql.example.edu
DB_PORT=3306
DB_NAME=omeka_s
DB_USER=omeka_s
```

Put the application account password in `secrets/OMEKA_S_DB_PASSWORD`. Preserve existing secrets and the files volume. The base deployment does not start MariaDB or initialize the database, and the application does not receive the root password.

PHP `mail()` is routed through `msmtp`. By default, Omeka S relays through the Docker host so production delivery can use the host MTA and LibOps relay path.

## License

The Docker Compose template and LibOps-specific setup in this repository are licensed under the MIT License. Omeka S is licensed separately under the GNU General Public License v3; see `LICENSE.omeka-s`.
