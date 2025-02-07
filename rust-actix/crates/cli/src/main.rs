#![allow(unused_must_use)]

use std::process::exit;

use clap::Parser;
use cli::{
    config::{Config, Field},
    Cli, Commands, ConfigCommands, ServerCommands,
};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let args = Cli::parse();
    let mut config = Config::new();

    match args.command {
        // bin ...
        Commands::Server(srv) => {
            // bin server ...
            match srv.command {
                ServerCommands::Env => {
                    match config.env() {
                      Ok(_) => println!("Necessary keys and variables has been loaded from environmental variables!"),
                      Err(e) => {
                        println!("{}", e);
                        exit(1);
                      }
                    };

                    http::server((config.url, config.port.parse::<u16>().unwrap_or(8000))).await;
                }
                ServerCommands::Config { path } => {
                    match config.import(path) {
                        Ok(_) => println!("Configration has been loaded successfully!"),
                        Err(e) => {
                            println!("Oops, failed loading configurations: {}", e);
                            exit(1);
                        }
                    };

                    http::server((config.url, config.port.parse::<u16>().unwrap_or(8000))).await;
                }
            };
        }
        Commands::Config(cfg) => match cfg.command {
            ConfigCommands::Generate {
                path,
                port,
                url,
                database,
            } => {
                for set in [("url", url), ("port", port), ("database", database)] {
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
                match cli::config::Config::validate(path) {
                    Ok(_) => println!("Configuration seems to be fine!"),
                    Err(e) => println!("There's something wrong with it:\n{}", e),
                };
            }
        },
    };

    Ok(())
}
