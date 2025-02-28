use actix_web::{get, HttpResponse, Responder};

pub mod posts;

#[get("/")]
async fn index() -> impl Responder {
    HttpResponse::Ok().body("Hello world!")
}
