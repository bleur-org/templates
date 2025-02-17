use actix_web::{
    dev::{ServiceFactory, ServiceRequest},
    web, App, Error, HttpResponse, Responder,
};

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

struct Router<T>
where
    T: ServiceFactory<ServiceRequest, Config = (), Error = Error, InitError = ()>,
{
    app: App<T>,
}

impl<T> Router<T>
where
    T: ServiceFactory<ServiceRequest, Config = (), Error = Error, InitError = ()>,
{
    fn new() -> Self {
        Self {
            app: App::new()
                .service(hello)
                .service(echo)
                .route("/hey", web::get().to(manual_hello)),
        }
    }
}
