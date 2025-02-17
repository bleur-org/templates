pub mod posts;
pub mod schema;

use diesel::{prelude::*, r2d2};
use dotenvy::dotenv;

/// Short-hand for the database pool type to use throughout the app.
pub type DbPool = r2d2::Pool<r2d2::ConnectionManager<PgConnection>>;

/// One time database establishment for a single request
pub fn establish_connection(database_url: String) -> PgConnection {
    dotenv().ok();

    PgConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url))
}

/// Initialize database connection pool based on database_url parameter.
///
/// See more: <https://docs.rs/diesel/latest/diesel/r2d2/index.html>.
pub fn initialize_db_pool(database_url: String) -> DbPool {
    let manager = r2d2::ConnectionManager::<PgConnection>::new(database_url);
    r2d2::Pool::builder()
        .build(manager)
        .expect("database URL should be valid path to SQLite DB file")
}
