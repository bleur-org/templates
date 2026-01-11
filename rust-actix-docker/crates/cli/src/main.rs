#![allow(unused_must_use)]

use std::process::exit;

use clap::Parser;
use cli::{Cli, Commands, ConfigCommands, ServerCommands};
use utils::config::{Config, Field};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let args = Cli::parse();
    let mut config = Config::new();

    match args.command {
        // bin ...
        Commands::Server(srv) => {
            // bin server ...
            match srv.command {
                ServerCommands::Run { path } => {
                    match config.import(path) {
                        Ok(_) => println!("Configration has been loaded successfully!"),
                        Err(e) => {
                            println!("Oops, failed loading configurations: {}", e);
                            exit(1);
                        }
                    };

                    http::server(config).await;
                }
            };
        }
        Commands::Config(cfg) => match cfg.command {
            ConfigCommands::Generate {
                path,
                port,
                url,
                threads,
                database,
            } => {
                for set in [
                    ("url", url),
                    ("port", port),
                    ("database", database),
                    ("threads", threads),
                ] {
                    if let Some(val) = set.1 {
                        match set.0 {
                            "url" => {
                                config.set(Field::Url, val).ok();
                            }
                            "port" => {
                                config.set(Field::Port, val).ok();
                            }
                            "database" => {
                                config.set(Field::Database, val).ok();
                            }
                            "threads" => {
                                config.set(Field::Threads, val).ok();
                            }
                            _ => {
                                println!("Whoops, unimplemented value type!");
                            }
                        }
                    }
                }

                println!("Writing configurations at: {}", path.to_string_lossy());
                config.export(path).ok();
            }
            ConfigCommands::Check { path } => {
                match utils::config::Config::validate(path) {
                    Ok(_) => println!("Configuration seems to be fine!"),
                    Err(e) => println!("There's something wrong with it:\n{}", e),
                };
            }
        },
    };

    Ok(())
}
