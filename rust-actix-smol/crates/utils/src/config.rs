use crate::error::{Error, Result};
use get_fields::GetFields;
use serde::{Deserialize, Serialize};
use std::{net::ToSocketAddrs, path::PathBuf};

#[derive(Debug, Serialize, Deserialize, GetFields)]
#[get_fields(rename_all = "SCREAMING_SNAKE_CASE")]
pub struct Config {
    pub url: String,
    pub port: u16,
    pub database_url: String,
    pub threads: u16,
}

pub struct Builder {
    instance: Config,
}

pub enum Field {
    Url,
    Port,
    Database,
    Unknown,
    Threads,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            threads: 1,
            port: 8001,
            url: "127.0.0.1".to_string(),
            database_url: String::new(),
        }
    }
}

impl Config {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn set<T>(&mut self, field: Field, data: T) -> Result<()>
    where
        T: ToString,
    {
        match field {
            Field::Url => self.url = data.to_string(),
            Field::Port => {
                self.port = data
                    .to_string()
                    .parse::<u16>()
                    .map_err(Error::NumberConversion)?
            }
            Field::Database => self.database_url = data.to_string(),
            Field::Threads => {
                self.threads = data
                    .to_string()
                    .parse::<u16>()
                    .map_err(Error::NumberConversion)?
            }
            Field::Unknown => {}
        };

        Ok(())
    }

    /// Read a file at given path and return it as String
    fn read_file(path: PathBuf) -> Result<String> {
        if !(path.is_absolute()) {
            return Err(Error::NonExistent("Given path is not absolute".to_string()));
        }

        if !(path.is_file()) {
            return Err(Error::NonExistent(
                "This file probably doesn't exist".to_string(),
            ));
        }

        let result = match std::fs::read_to_string(path) {
            Ok(d) => d,
            Err(e) => return Err(Error::Read(e)),
        };

        Ok(result)
    }

    /// Save current instance of configuration to a file
    pub fn export(&self, mut path: PathBuf) -> Result<()> {
        if path.extension().and_then(|ext| ext.to_str()) != Some("toml") {
            path = path.join("config.toml");
        }

        let output = toml::to_string_pretty(self).map_err(Error::Serialization)?;
        std::fs::write(&path, output).map_err(Error::Write)?;

        Ok(())
    }

    /// Read a file at given path, parse and set values to current instance
    pub fn import(&mut self, path: PathBuf) -> Result<()> {
        let file = std::fs::read_to_string(&path).map_err(Error::Read)?;
        let new: Config = toml::from_str(&file).map_err(Error::Deserialization)?;

        *self = new;

        Ok(())
    }

    /// Attempt to deserialize a file at given path
    pub fn validate(path: PathBuf) -> Result<()> {
        let file = Config::read_file(path)?;
        toml::from_str::<Config>(&file).map_err(Error::Deserialization)?;

        Ok(())
    }

    /// Produce socket address parsable String from instance values
    pub fn socket_addr(&self) -> Result<String> {
        let addr: String = (self.url.clone(), self.port)
            .to_socket_addrs()
            .map_err(Error::SocketParse)?
            .map(|p| p.to_string())
            .collect::<String>();

        println!("Server is getting started at: http://{}", addr);

        Ok(addr)
    }
}
