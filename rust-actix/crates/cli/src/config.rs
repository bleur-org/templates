use crate::error::{Error, Result};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Serialize, Deserialize)]
pub struct Config {
    pub url: String,
    pub port: String,
    pub database: String,
}

pub enum Field {
    Url,
    Port,
    Database,
    Unknown,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            url: "127.0.0.1".to_string(),
            port: "8001".to_string(),
            database: String::new(),
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
            Field::Port => self.port = data.to_string(),
            Field::Database => self.database = data.to_string(),
            Field::Unknown => {}
        };

        Ok(())
    }

    pub fn read<T>(&mut self, field: Field, path: PathBuf) -> Result<()> {
        let data = self.parse_file(path)?;

        match field {
            Field::Url => self.url = data.to_string(),
            Field::Port => self.port = data.to_string(),
            Field::Database => self.database = data.to_string(),
            Field::Unknown => {}
        };

        Ok(())
    }

    fn parse_file(&self, path: PathBuf) -> Result<String> {
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

    pub fn env(&mut self) -> Result<()> {
        let keys = [
            "URL",          // 0. struct -> url      | Url to host the app
            "PORT",         // 1. struct -> port     | Port to listen
            "DATABASE_URL", // 2. struct -> database | Database connection url
        ];

        for key in keys {
            let value = std::env::var(key).map_err(Error::EnvRead)?;

            let field = match key {
                "URL" => Field::Url,
                "PORT" => Field::Port,
                "DATABASE_URL" => Field::Database,
                _ => Field::Unknown,
            };

            self.set(field, value)?;
        }

        Ok(())
    }

    pub fn export(&self, mut path: PathBuf) -> Result<()> {
        if path.extension().and_then(|ext| ext.to_str()) != Some("toml") {
            path = path.join("config.toml");
        }

        let output = toml::to_string_pretty(self).map_err(Error::Serialization)?;

        std::fs::write(&path, output).map_err(Error::Write)?;

        Ok(())
    }

    pub fn import(&mut self, path: PathBuf) -> Result<()> {
        let file = std::fs::read_to_string(&path).map_err(Error::Read)?;
        let new: Config = toml::from_str(&file).map_err(Error::Deserialization)?;

        *self = new;

        Ok(())
    }

    pub fn validate(path: PathBuf) -> Result<()> {
        let file = std::fs::read_to_string(&path).map_err(Error::Read)?;

        toml::from_str::<Config>(&file).map_err(Error::Deserialization)?;

        Ok(())
    }
}
