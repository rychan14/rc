extern crate actix;
extern crate actix_web;
extern crate env_logger;
extern crate askama;
extern crate dotenv;
extern crate serde;
#[macro_use]
extern crate serde_derive;
extern crate serde_json;

use std::env;
// use actix::prelude::*;
use actix_web::{
    fs,
    http,
    // middleware,
    server, 
    App, 
    // AsyncResponder,
    Error, 
    // FutureResponse,
    HttpRequest, 
    HttpResponse, 
    // Json,
    // State,
};
use dotenv::dotenv;
// use fs::NamedFile;
use askama::Template;

#[derive(Template)]
#[template(path = "index.html")]
struct RootTemplate<'a> {
    api_key: &'a str,
}

#[derive(Deserialize, Serialize)]
struct Data {
    temp: f64
}


fn index(_req: &HttpRequest) -> Result<HttpResponse, Error> {
    dotenv().ok();
    let api_key = env::var("WEATHER_API_KEY").expect("WEATHER_API_KEY not found");
    let root_template = RootTemplate { api_key: &api_key }.render().unwrap();
    Ok(HttpResponse::Ok().content_type("text/html").body(root_template))
}

fn get_api(_req: &HttpRequest) -> HttpResponse {
    HttpResponse::Ok()
        // .content_encoding(http::ContentEncoding::Br)
        .content_type("application/json")
        .body(serde_json::to_string(&Data {
            temp: 10.0
        }).unwrap())
}

fn main() {
    ::std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();
    let host = "localhost:3000";
    let sys = actix::System::new("rc");
    server::new(move || {
        vec![ App::new()
                .prefix("api")
                .resource("/data", |r| r.method(http::Method::GET).f(get_api)),
            App::new()
                .resource("/", |r| r.f(index))
                // .handler("/img", fs::StaticFiles::new("ui/dist/img").expect("fail to handle static images"))
                .handler("/dist", fs::StaticFiles::new("app/dist").expect("fail to handle static js"))
                // .handler("/css", fs::StaticFiles::new("app/dist/static/css").expect("fail to handle static css"))
                // .handler("/", fs::StaticFiles::new("ui/dist").expect("fail to handle static files"))
        ]
    }).bind(host)
        .expect(&format!("could not bind to {}", host))
        .start();

    println!("Starting http server: {}", host);
    let _ = sys.run();
}