pub mod posts;
pub mod schema;

use diesel::prelude::*;
use dotenvy::dotenv;
use std::env;

pub fn establish_connection(database_url: String) -> PgConnection {
    dotenv().ok();

    PgConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url))
}
