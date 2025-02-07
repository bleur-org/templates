use std::net::ToSocketAddrs;

use actix_web::{get, post, web, App, HttpResponse, HttpServer, Responder};

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

pub async fn server<T>(address: T) -> std::io::Result<()>
where
    T: ToSocketAddrs,
{
    match address.to_socket_addrs() {
        Ok(sock) => {
            println!(
                "Server is getting started at: http://{}",
                sock.map(|p| p.to_string()).collect::<String>()
            );
        }
        Err(_) => {
            println!("I can feel as if something not good is about to happen...");
        }
    }

    HttpServer::new(|| {
        App::new()
            .service(hello)
            .service(echo)
            .route("/hey", web::get().to(manual_hello))
    })
    .bind(address)?
    .run()
    .await
}
