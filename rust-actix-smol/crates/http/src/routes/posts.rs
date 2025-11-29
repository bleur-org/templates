use actix_web::{delete, error, get, post, put, web, HttpResponse, Responder};
use database::{
    posts::{NewPost, UpdatePost},
    DbPool,
};

#[get("/post")]
async fn all_posts(pool: web::Data<DbPool>) -> actix_web::Result<impl Responder> {
    let posts = web::block(move || {
        // use web::block to offload blocking Diesel queries without blocking server thread
        let mut conn = pool.get()?;

        database::posts::get_all_posts(&mut conn)
    })
    .await?
    .map_err(error::ErrorInternalServerError)?;

    Ok(HttpResponse::Ok().json(posts))
}

#[get("/post/{id}")]
async fn get_post(
    pool: web::Data<DbPool>,
    path: web::Path<(i32,)>,
) -> actix_web::Result<impl Responder> {
    let post_id = path.into_inner().0;

    // use web::block to offload blocking Diesel queries without blocking server thread
    let post = web::block(move || {
        // note that obtaining a connection from the pool is also potentially blocking
        let mut conn = pool.get()?;

        database::posts::find_post_by_uid(&mut conn, post_id)
    })
    .await?
    // map diesel query errors to a 500 error response
    .map_err(error::ErrorInternalServerError)?;

    Ok(match post {
        // post was found; return 200 response with JSON formatted post object
        Some(post) => HttpResponse::Ok().json(post),

        // post was not found; return 404 response with error message
        None => HttpResponse::NotFound().body(format!("No post found with UID: {post_id}")),
    })
}

#[post("/post")]
async fn new_post(
    pool: web::Data<DbPool>,
    form: web::Json<NewPost>,
) -> actix_web::Result<impl Responder> {
    // use web::block to offload blocking Diesel queries without blocking server thread
    let post = web::block(move || {
        // note that obtaining a connection from the pool is also potentially blocking
        let mut conn = pool.get()?;

        database::posts::insert_new_post(&mut conn, &form.title, &form.body)
    })
    .await?
    // map diesel query errors to a 500 error response
    .map_err(error::ErrorInternalServerError)?;

    // post was added successfully; return 201 response with new user info
    Ok(HttpResponse::Created().json(post))
}

#[put("/post/{id}")]
async fn edit_post(
    pool: web::Data<DbPool>,
    path: web::Path<(i32,)>,
    form: web::Json<UpdatePost>,
) -> actix_web::Result<impl Responder> {
    let post_id = path.into_inner().0;

    // use web::block to offload blocking Diesel queries without blocking server thread
    let update = web::block(move || {
        // note that obtaining a connection from the pool is also potentially blocking
        let mut conn = pool.get()?;

        database::posts::update_post(&mut conn, post_id, &form.into_inner())
    })
    .await?
    // map diesel query errors to a 500 error response
    .map_err(error::ErrorInternalServerError)?;

    // post was added successfully; return 201 response with new user info
    Ok(HttpResponse::Ok().json(update))
}

#[delete("/post/{id}")]
async fn remove_post(
    pool: web::Data<DbPool>,
    path: web::Path<(i32,)>,
) -> actix_web::Result<impl Responder> {
    let post_id = path.into_inner().0;

    web::block(move || {
        // note that obtaining a connection from the pool is also potentially blocking
        let mut conn = pool.get()?;

        database::posts::remove_post(&mut conn, post_id)
    })
    .await?
    // map diesel query errors to a 500 error response
    .map_err(error::ErrorInternalServerError)?;

    Ok(HttpResponse::Ok().body(format!(
        "Post with {post_id} has been deleted successfully!"
    )))
}
