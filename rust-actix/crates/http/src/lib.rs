use actix_web::{get, post, web, App, HttpResponse, HttpServer, Responder};
use utils::config::Config;

mod routes;

#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello world!")
}

#[post("/echo")]
async fn echo(req_body: String) -> impl Responder {
    HttpResponse::Ok().body(req_body)
}

async fn manual_hello() -> impl Responder {
    HttpResponse::Ok().body("Hey there!")
}

pub async fn server(config: Config) -> std::io::Result<()> {
    // Logger setup
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    HttpServer::new(|| {
        App::new()
            .service(hello)
            .service(echo)
            .route("/hey", web::get().to(manual_hello))
    })
    .workers(config.threads as usize)
    .bind(config.socket_addr().unwrap_or("127.0.0.1:8000".to_string()))?
    .run()
    .await
}
