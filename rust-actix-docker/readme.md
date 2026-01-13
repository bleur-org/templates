# Rust + Actix + Diesel + Postgres Template

A simple Rust workspace template for an Actix Web server + Diesel + Postgres, with dev/prod compose setups and `just` recipes.

---

## Prereqs

- **Podman/Docker** (default Podman)
- `just` (optional)

---

## If you use **Docker** instead of Podman:
- open `justfile` and change:

```make
dc := "podman-compose"
````
to:
```make
dc := "docker compose"
```

---

## Setup

### 1) Env vars

```bash
cp .env.example .env
```

### 2) Create `config.toml`

`config.toml` is **not committed** (gitignored). You have two options:

**Option A — generate it with the CLI:**

```bash
cargo run --bin server -- config generate ./config.toml" # reads .env file
```

**Option B — write it manually (minimal example):**

```toml
url = "0.0.0.0"
port = 8001
threads = 1
database_url = "postgres://temp:temp@postgres:5432/temp"
```

Important:

* In containers, the Postgres host is **`postgres`** (the compose service name), not `localhost`.

---

## Using `just` (what the commands actually mean)

This template has two “modes”: **dev** and **prod**.

* **dev** uses `docker/docker-compose.dev.yml`
* **prod** uses `docker/docker-compose.yml`

Most recipes accept `env="dev"` by default; you can pass `prod` explicitly.

### Start dev stack (default)

```bash
just
# same as:
just dev
```

What it does:

* `just up` → starts containers in the background
* `just migrate` → runs Diesel migrations against the Postgres container

### Start prod stack

```bash
just prod
```

### Useful commands

```bash
just up            # start dev containers
just up prod       # start prod containers

just down          # stop dev containers
just down prod     # stop prod containers

just logs          # follow dev logs
just logs prod     # follow prod logs

just migrate       # run migrations (dev)
just migrate prod  # run migrations (prod)
```

### Shell into containers

App container (dev by default):

```bash
just shell
```

Postgres psql:

```bash
just db
```

---

## Ports

* **Dev app:** `http://localhost:8002`
* **Prod app:** `http://localhost:8001`
* **Postgres (dev):** `localhost:${DB_PORT}` → container `5432`

---

## Clean reset

Removes build outputs + stops/removes containers/volumes:

```bash
just clean
```
