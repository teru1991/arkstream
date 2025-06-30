use dotenvy::dotenv;
use sqlx::{postgres::PgPoolOptions, Row};
use std::env;

#[tokio::test]
async fn test_postgres_connection() {
    dotenv().ok(); // .envから環境変数読み込み（任意）

    let db_url = env::var("POSTGRES_URL").expect("POSTGRES_URL not set");
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&db_url)
        .await
        .expect("Failed to connect to DB");

    let row: (i32,) = sqlx::query_as("SELECT 1").fetch_one(&pool).await.expect("Failed to fetch");

    assert_eq!(row.0, 1);
}
