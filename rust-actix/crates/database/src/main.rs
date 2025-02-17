/// Use this binary as a playground for playing with
/// your schemes, database and functions that you will
/// be calling from http crate!
///
use database::establish_connection;
use database::posts::*;
use diesel::prelude::*;

fn main() {
    use database::schema::posts::dsl::*;

    let connection =
        &mut establish_connection("postgres://sakhib:sakhib@localhost/temp".to_string());
    let results = posts
        .filter(published.eq(true))
        .limit(5)
        .select(Post::as_select())
        .load(connection)
        .expect("Error loading posts");

    println!("Displaying {} posts", results.len());
    for post in results {
        println!("{}", post.title);
        println!("-----------\n");
        println!("{}", post.body);
    }
}
