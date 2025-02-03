use clap::Parser;
use std::error::Error;
use teloxide::{prelude::*, update_listeners::webhooks};
use tempbot::bot::dispatch;
use tempbot::clog;
use tempbot::config::{Config, Field};
use tempbot::{Cli, Commands};

/// # Welcome to our Telegram Bot Template
///
/// Before you start doing anything, make sure to read this instruction at least once,
/// so you know later what where to add/change/remove.
///
/// ## Database, HTTP Clients or whatever global thing
///
/// Should be instantiated at `Global instance` section as variable and then passed to
/// `Dependencies` inside `dptree::deps macro`. Also, it worth to mention that you
/// shouldn't attempt to pass mutable references to dependencies, it won't work. Instead,
/// wrap it to Arc<Mutex<T>> and then pass to deps. Make sure that dependency implements
/// `Clone` and whatever Error in that deps implements Send + Sync + 'static.
///
/// ## Commands
///
/// Oh yes, at first, you need to declare available commands at `src/bot.rs` inside
/// `Command` enum. Afterwards, you need to add it to `src/functions/mod.rs` inside
/// `commands` functions and pass whatever global instance & shared state you would
/// need in your command logic. Finally, you can literally copy & paste start.rs as a
/// template for your new command, rename the file and edit the contents inside your
/// command file.
///
/// ## Deployment
///
/// For further information about deploying your bot in your NixOS server, please, refer
/// to readme.md.

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    // Starter packs
    pretty_env_logger::init();
    log::info!("Starting Bot: {}", "xinuxmgr");

    // Global instances
    let mut config = Config::default();

    // Dependencies
    let deps = dptree::deps![];

    // Args
    let args = Cli::parse();

    match args.command {
        Commands::Polling { token } => {
            match config.read(token, Field::Token) {
                Ok(_) => clog("Config", "Successfully read the token variable"),
                Err(e) => panic!("{}", e),
            };

            let bot = Bot::new(config.token);
            let mut dispatcher = dispatch(&bot, deps);

            clog("Mode", "starting polling on localhost");
            dispatcher.dispatch().await;

            Ok(())
        }
        Commands::Webhook {
            token,
            domain,
            port,
        } => {
            match config.read(token, Field::Token) {
                Ok(_) => clog("Config", "Successfully read the token variable"),
                Err(e) => panic!("{}", e),
            };

            match config.set(format!("https://{}", domain), Field::Domain) {
                Ok(_) => clog("Config", "Successfully set the domain variable"),
                Err(e) => panic!("{}", e),
            }

            let bot = Bot::new(config.token);
            let mut dispatcher = dispatch(&bot, deps);

            let addr = ([127, 0, 0, 1], port.unwrap_or(8445)).into(); // port 8445
            let listener = webhooks::axum(
                bot,
                webhooks::Options::new(addr, config.domain.parse().unwrap()),
            )
            .await
            .expect("Couldn't setup webhook");

            dispatcher
                .dispatch_with_listener(
                    listener,
                    LoggingErrorHandler::with_custom_text(
                        "An error has occurred in the dispatcher",
                    ),
                )
                .await;

            Ok(())
        }
        Commands::Env => {
            let bot = Bot::from_env();
            let mut dispatcher = dispatch(&bot, deps);

            match std::env::var("WEBHOOK_URL") {
                Ok(v) => {
                    clog("Mode", &format!("starting webhook on {}", v));

                    let port: u16 = std::env::var("PORT")
                        .unwrap_or("8445".to_string())
                        .parse()
                        .unwrap_or(8445);

                    let addr = ([0, 0, 0, 0], port).into();

                    let listener =
                        webhooks::axum(bot, webhooks::Options::new(addr, v.parse().unwrap()))
                            .await
                            .expect("Couldn't setup webhook");

                    dispatcher
                        .dispatch_with_listener(
                            listener,
                            LoggingErrorHandler::with_custom_text(
                                "An error has occurred in the dispatcher",
                            ),
                        )
                        .await;
                }
                Err(_) => {
                    clog("Mode", "starting polling on localhost");
                    dispatcher.dispatch().await;
                }
            }

            Ok(())
        }
    }
}
