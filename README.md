# Installing Odoo 18.0 with one command (Supports multiple Odoo instances on one server).

## Quick Installation

Install [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/) yourself, then run the following to set up first Odoo instance @ `localhost:10018` (default master password: `XF-Odoo-18-Docker-Compose*`):

``` bash
curl -s https://raw.githubusercontent.com/XaviFortes/Odoo-18-Docker-Compose/master/run.sh | bash -s odoo-one 10018 20018
```
and/or run the following to set up another Odoo instance @ `localhost:11018` (default master password: `XF-Odoo-18-Docker-Compose*`):

``` bash
curl -s https://raw.githubusercontent.com/XaviFortes/Odoo-18-Docker-Compose/master/run.sh | bash -s odoo-two 11018 21018
```

Some arguments:
* First argument (**odoo-one**): Odoo deploy folder
* Second argument (**10017**): Odoo port
* Third argument (**20017**): live chat port

If `curl` is not found, install it:

``` bash
$ sudo apt-get install curl
# or
$ sudo yum install curl
```

## Usage

Start the container:
``` sh
docker-compose up
```
Then open `localhost:10018` to access Odoo 18.

- **If you get any permission issues**, change the folder permission to make sure that the container is able to access the directory:

``` sh
$ sudo chmod -R 777 addons
$ sudo chmod -R 777 etc
$ sudo chmod -R 777 postgresql
```

- If you want to start the server with a different port, change **10018** to another value in **docker-compose.yml** inside the parent dir:

```
ports:
 - "10018:8069"
```

- To run Odoo container in detached mode (be able to close terminal without stopping Odoo):

```
docker-compose up -d
```

- To Use a restart policy, i.e. configure the restart policy for a container, change the value related to **restart** key in **docker-compose.yml** file to one of the following:
   - `no` =	Do not automatically restart the container. (the default)
   - `on-failure[:max-retries]` =	Restart the container if it exits due to an error, which manifests as a non-zero exit code. Optionally, limit the number of times the Docker daemon attempts to restart the container using the :max-retries option.
  - `always` =	Always restart the container if it stops. If it is manually stopped, it is restarted only when Docker daemon restarts or the container itself is manually restarted. (See the second bullet listed in restart policy details)
  - `unless-stopped`	= Similar to always, except that when the container is stopped (manually or otherwise), it is not restarted even after Docker daemon restarts.
```
 restart: always             # run as a service
```

- To increase maximum number of files watching from 8192 (default) to **524288**. In order to avoid error when we run multiple Odoo instances. This is an *optional step*. These commands are for Ubuntu user:

```
$ if grep -qF "fs.inotify.max_user_watches" /etc/sysctl.conf; then echo $(grep -F "fs.inotify.max_user_watches" /etc/sysctl.conf); else echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf; fi
$ sudo sysctl -p    # apply new config immediately
``` 

## Custom addons

The **addons/** folder contains custom addons. Just put your custom addons if you have any.

## Odoo configuration & log

* To change Odoo configuration, edit file: **etc/odoo.conf**.
* Log file: **etc/odoo-server.log**
* Default database password (**admin_passwd**) is `XF-Odoo-18-Docker-Compose*`, please change it @ [etc/odoo.conf#L60](/etc/odoo.conf#L60)

## Odoo container management

**Run Odoo**:

``` bash
docker-compose up -d
```

**Restart Odoo**:

``` bash
docker-compose restart
```

**Stop Odoo**:

``` bash
docker-compose down
```
# Odoo 18 Docker Compose

This repository provides a minimal Docker Compose setup to run Odoo 18 with PostgreSQL and support for mounting custom addons. It is aimed at local development and testing and supports running multiple Odoo instances on one host.

**Repository**: `https://github.com/XaviFortes/Odoo-18-Docker-Compose`

**Author**: `Xavi Fortes` — `https://github.com/XaviFortes`

## Quick Start

Requirements:
- Docker
- docker-compose

Start a single Odoo 18 instance (HTTP on `localhost:10018`):

```bash
docker-compose up -d
```

Open `http://localhost:10018` in your browser.

Alternatively use the `run.sh` helper to create a new instance directory and start it (example):

```bash
curl -s https://raw.githubusercontent.com/XaviFortes/Odoo-18-Docker-Compose/master/run.sh | bash -s odoo-one 10018 20018
```

## Multiple Instances

You can run multiple Odoo containers on the same machine by using different host ports for each instance. Example port mappings:

- Instance A: `10018` → Odoo, `20018` → longpolling
- Instance B: `11018` → Odoo, `21018` → longpolling

Use the `run.sh` helper to automate creating separate folders and port choices.

## Project Layout

- `docker-compose.yml` — Compose file with `odoo18` and `db` services
- `addons/` — Place custom addons here (mounted to `/mnt/extra-addons`)
- `etc/odoo.conf` — Odoo configuration used by the container
- `postgresql/` — PostgreSQL data directory

## Configuration Notes

- Default database credentials in `docker-compose.yml`: `POSTGRES_USER=odoo`, `POSTGRES_PASSWORD=odoo18@2024`. Change before production.
- Default Odoo `admin_passwd` is in `etc/odoo.conf` — change it before exposing to production.

To change the external ports used by the container, edit `docker-compose.yml` and update the `ports` section under the `odoo18` service, e.g.:

```yaml
ports:
    - "10018:8069"
    - "20018:8072"
```

## Useful Commands

- Start (detached): `docker-compose up -d`
- Start (foreground): `docker-compose up`
- Stop: `docker-compose down`
- Restart: `docker-compose restart`

These commands work in Linux/macOS shells and Windows PowerShell alike when run from the repository root.

## Longpolling / Live Chat

If you map the longpolling port to the host, configure your reverse proxy to forward `/longpolling/` to that host port. Example nginx snippet:

```nginx
location /longpolling/ {
    proxy_pass http://127.0.0.1:20018/longpolling/;
}
```

## Troubleshooting

- Permission errors for mounted directories: ensure the container user can read them. On Linux adjust permissions:

```bash
sudo chmod -R 755 addons etc postgresql
```

- If you run many instances you may need to increase inotify watches on Linux:

```bash
echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## Production Considerations

This compose file is provided for development/testing. For production usage consider:

- Using secrets or environment variables instead of plaintext passwords in `docker-compose.yml`.
- Placing Odoo behind a TLS-enabled reverse proxy.
- Running PostgreSQL with proper backup and secure storage.

## License

If you plan to publish this repository, add a `LICENSE` file (for example, `MIT`) to clarify reuse terms.

---

Need anything else? I can:

- Update `run.sh` and `entrypoint.sh` to default to `10018/20018` and the `odoo18` service name.
- Add a `LICENSE` file (MIT) if you'd like.

