#![allow(unused_variables)]
#![allow(clippy::single_match)]

pub mod bot;
pub mod config;
pub mod functions;

use clap::{Parser, Subcommand};
use std::path::PathBuf;

/// Telegram bot made with Bleur Stack
#[derive(Debug, Parser)]
#[command(name = "bot")]
#[command(about = "Telegram bot made with Bleur Stack", long_about = None)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Debug, Subcommand)]
pub enum Commands {
    /// Start bot in Polling mode with token
    #[command(arg_required_else_help = true)]
    Polling {
        /// Telegram bot token
        #[arg(required = true)]
        token: PathBuf,
    },
    /// Start bot in Webhook mode with given variables
    // #[command(arg_required_else_help = true)]
    Webhook {
        /// Telegram bot token
        #[arg(required = true)]
        token: PathBuf,

        /// Domain url to set webhook address
        #[arg(required = true)]
        domain: String,

        /// Port to host webserver at
        #[arg(short, long)]
        port: Option<u16>,
    },
    /// Start bot by getting necessary configurations from environmental variables
    Env,
}

pub fn clog(title: &str, message: &str) {
    let title = if title.len() > 12 {
        title[..8].to_string() + "..."
    } else {
        title.to_string()
    };

    println!(
        "{}\x1b[1;32m{}\x1b[0m {} {}",
        " ".repeat(12 - title.len()),
        title,
        message,
        " ".repeat(8)
    );
}
