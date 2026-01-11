use crate::{schema::posts, DbError};
use diesel::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Queryable, Selectable, Serialize, Deserialize, Debug, Clone)]
#[diesel(table_name = posts)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Post {
    pub id: i32,
    pub title: String,
    pub body: String,
    pub published: bool,
}

#[derive(Insertable, Serialize, Deserialize, Debug, Clone)]
#[diesel(table_name = posts)]
pub struct NewPost {
    pub title: String,
    pub body: String,
}

#[derive(AsChangeset, Serialize, Deserialize, Debug, Clone)]
#[diesel(table_name = posts)]
pub struct UpdatePost {
    pub title: String,
    pub body: String,
    pub published: bool,
}

/// Run query using Diesel to find post by uid and return it.
pub fn get_all_posts(conn: &mut PgConnection) -> Result<Vec<Post>, DbError> {
    use crate::schema::posts::dsl::*;

    // let posts = posts.filter(id.eq(uid)).first::<Post>(conn).optional()?;
    let all_posts = posts.select(Post::as_select()).limit(20).load(conn)?;

    Ok(all_posts)
}

/// Run query using Diesel to find post by uid and return it.
pub fn find_post_by_uid(conn: &mut PgConnection, uid: i32) -> Result<Option<Post>, DbError> {
    use crate::schema::posts::dsl::*;

    let post = posts.filter(id.eq(uid)).first::<Post>(conn).optional()?;

    Ok(post)
}

/// Run query using Diesel to insert a new database row and return the result.
pub fn insert_new_post(
    conn: &mut PgConnection,
    ttl: &str, // prevent collision with `title` column imported inside the function
    bdy: &str, // prevent collision with `body` column imported inside the function
) -> Result<NewPost, DbError> {
    // It is common when using Diesel with Actix Web to import schema-related
    // modules inside a function's scope (rather than the normal module's scope)
    // to prevent import collisions and namespace pollution.
    use crate::schema::posts::dsl::*;

    let new_post = NewPost {
        title: ttl.to_owned(),
        body: bdy.to_owned(),
    };

    diesel::insert_into(posts).values(&new_post).execute(conn)?;

    Ok(new_post)
}

/// Run query using Diesel to insert a new database row and return the result.
pub fn update_post(
    conn: &mut PgConnection,
    pid: i32, // prevent collision with `title` column imported inside the function
    content: &UpdatePost, // prevent collision with `body` column imported inside the function
) -> Result<UpdatePost, DbError> {
    // It is common when using Diesel with Actix Web to import schema-related
    // modules inside a function's scope (rather than the normal module's scope)
    // to prevent import collisions and namespace pollution.
    use crate::schema::posts::dsl::*;

    diesel::update(posts.find(pid)).set(content).execute(conn)?;

    Ok(content.clone())
}

pub fn remove_post(
    conn: &mut PgConnection,
    pid: i32, // prevent collision with `title` column imported inside the function
) -> Result<(), DbError> {
    // It is common when using Diesel with Actix Web to import schema-related
    // modules inside a function's scope (rather than the normal module's scope)
    // to prevent import collisions and namespace pollution.
    use crate::schema::posts::dsl::*;

    diesel::delete(posts.find(pid)).execute(conn)?;

    Ok(())
}
