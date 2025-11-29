use std::fmt::{Debug, Display, Formatter};

pub type Result<T> = std::result::Result<T, Error>;

#[non_exhaustive]
pub enum Error {
    MainFailure,
    NonExistent(String),
    Write(std::io::Error),
    Read(std::io::Error),
    EnvLoad(dotenvy::Error),
    SocketParse(std::io::Error),
    EnvRead(std::env::VarError),
    NumberConversion(std::num::ParseIntError),
    Serialization(toml::ser::Error),
    Deserialization(toml::de::Error),
}

impl Display for Error {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        match self {
            Error::MainFailure => write!(f, "Failed while starting main function!"),
            Error::Read(e) => write!(f, "Error while reading config: {}", e),
            Error::Write(e) => write!(f, "Error while writing config: {}", e),
            Error::NonExistent(e) => write!(f, "File is probably non existent: {}", e),
            Error::EnvLoad(e) => write!(f, "Error while reading .env variables: {}", e),
            Error::SocketParse(e) => write!(f, "Error while parsing address to SocketAddr: {}", e),
            Error::EnvRead(e) => write!(f, "Error while getting a variable: {}", e),
            Error::Serialization(e) => {
                write!(
                    f,
                    "Error while deserializing configuration to a file: {}",
                    e
                )
            }
            Error::NumberConversion(e) => {
                write!(f, "Error while parsing numbers from string, are you sure you typed normal number in configs?: {}", e)
            }
            Error::Deserialization(e) => {
                write!(
                    f,
                    "Error while deserializing configuration from file: {}",
                    e
                )
            }
        }
    }
}

impl Debug for Error {
    fn fmt(&self, f: &mut Formatter) -> std::fmt::Result {
        write!(f, "{}", self)
    }
}
