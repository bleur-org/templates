use orzklv::{telegram::keyboard::Keyboard, telegram::topic::Topics};
use teloxide::{
    payloads::SendMessageSetters,
    prelude::*,
    types::{InlineKeyboardMarkup, ParseMode},
};

static TEXT: &str = r#"
<b>Welcome to your bot!</b>

You're trying out a telegram bot made with Bleur Stack which is written on rust and has Nix deployment modules to get you started faster!
"#;

pub async fn command(bot: &Bot, msg: &Message) -> ResponseResult<()> {
    bot.send_message_tf(msg.chat.id, TEXT, msg)
        .parse_mode(ParseMode::Html)
        .reply_markup(keyboard())
        .await?;

    Ok(())
}

pub fn keyboard() -> InlineKeyboardMarkup {
    let mut keyboard = Keyboard::new();
    keyboard
        .url(
            "Maybe read more?",
            "https://github.com/bleur-org/templates/tree/main/rust-telegram",
        )
        .unwrap()
}
