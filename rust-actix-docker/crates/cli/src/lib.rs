use clap::{Args, Parser, Subcommand};
use std::path::PathBuf;

pub use utils::error::{Error, Result};

/// CLI interface for server infrastructure
#[derive(Debug, Parser)]
#[command(name = "server", version)]
#[command(about = "CLI interface for server infrastructure", long_about = None)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Debug, Subcommand)]
pub enum Commands {
    /// Commands for operating with server instance
    Server(ServerArgs),

    /// Commands for manging configurations
    Config(ConfigArgs),
}

#[derive(Debug, Args)]
#[command(flatten_help = true)]
pub struct ServerArgs {
    #[command(subcommand)]
    pub command: ServerCommands,
}

#[derive(Debug, Subcommand)]
pub enum ServerCommands {
    /// Starting server with reading a config file
    Run { path: PathBuf },
}

#[derive(Debug, Args)]
#[command(flatten_help = true)]
pub struct ConfigArgs {
    #[command(subcommand)]
    pub command: ConfigCommands,
}

#[derive(Debug, Subcommand)]
pub enum ConfigCommands {
    /// Starting server with reading a config file
    Check { path: PathBuf },

    /// Generate an example configuration configuration at given path
    Generate {
        path: PathBuf,
        port: Option<String>,
        url: Option<String>,
        threads: Option<String>,
        database: Option<String>,
    },
}
