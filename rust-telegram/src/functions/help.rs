use crate::bot::Command;
use orzklv::telegram::{keyboard::Keyboard, topic::Topics};
use teloxide::{
    payloads::SendMessageSetters,
    prelude::*,
    types::{InlineKeyboardMarkup, ParseMode},
};

static TEXT: &[(&str, &str)] = &[("help", "show this message")];

pub async fn command(bot: &Bot, msg: &Message, cmd: &Command) -> ResponseResult<()> {
    let mut text = String::new();

    text.push_str("<b>We have these commands available:</b>\n\n");

    for cmd in TEXT {
        text.push('/');
        text.push_str(cmd.0);
        text.push_str(" - ");
        text.push_str(format!("<code>{text}</code>", text = cmd.1).as_str());
        text.push('\n');
    }

    bot.send_message_tf(msg.chat.id, text, msg)
        .parse_mode(ParseMode::Html)
        .reply_markup(keyboard())
        .await?;

    Ok(())
}

pub fn keyboard() -> InlineKeyboardMarkup {
    let mut keyboard = Keyboard::new();
    keyboard.url("More", "https://xinux.uz").unwrap()
}
