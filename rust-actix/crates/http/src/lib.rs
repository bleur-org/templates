use actix_web::{web, App, HttpServer};
use database::{r2d2, PgConnection};
use utils::config::Config;

mod routes;

pub async fn server(config: Config) -> std::io::Result<()> {
    // Logger setup
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("trace"));

    let manager = r2d2::ConnectionManager::<PgConnection>::new(config.database_url.clone());
    let pool = r2d2::Pool::builder()
        .build(manager)
        .expect("seems like something is wrong with database_url coming from config!");

    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(pool.clone()))
            .service(routes::index)
            .service(routes::posts::all_posts)
            .service(routes::posts::get_post)
            .service(routes::posts::new_post)
            .service(routes::posts::edit_post)
            .service(routes::posts::remove_post)
    })
    .workers(config.threads as usize)
    .bind(config.socket_addr().unwrap_or("127.0.0.1:8000".to_string()))?
    .run()
    .await
}
