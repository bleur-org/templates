NIX_SHELL_DIR := source_dir() + "/.nix-shell"
PGDATA := NIX_SHELL_DIR + "/db"

set dotenv-filename := ".env"
set dotenv-load
set export

[doc('Start default server cli with default config')]
start:
  cargo run server run ./config.toml

[doc('Start specific package in the project')]
run crate:
  cargo run --bin {{crate}}

[doc('Lint your rust codebase with clippy')]
lint:
  cargo clippy

[doc('Format your codebase with rust formatter')]
format:
  cargo fmt

[working-directory('./crates/database')]
[confirm("Are you sure you want to do migration?")]
[doc('Perform migration with working database')]
migrate:
  diesel migration run

[confirm("Are you sure you want to delete all data & records?!")]
[doc('Clean up all mess created by development environment')]
clean: db-stop
  rm -rf .nix-shell
  rm -rf .env
  rm -rf target
  rm -rf result

[doc('Kill working postgres instance')]
db-stop:
  pkill postgres

[doc('Start postgresql instance with data')]
db-start:
  pg_ctl                                                  \
    -D "$PWD/.nix-shell/db"                               \
    -l $PGDATA/postgres.log                               \
    -o "-c unix_socket_directories='$PGDATA'"             \
    -o "-c listen_addresses='*'"                          \
    -o "-c log_destination='stderr'"                      \
    -o "-c logging_collector=on"                          \
    -o "-c log_directory='log'"                           \
    -o "-c log_filename='postgresql-%Y-%m-%d_%H%M%S.log'" \
    -o "-c log_min_messages=info"                         \
    -o "-c log_min_error_statement=info"                  \
    -o "-c log_connections=on"                            \
    start
