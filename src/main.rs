extern crate actix;
extern crate actix_web;
extern crate env_logger;
#[macro_use]
extern crate askama;
extern crate dotenv;

// use actix::prelude::*;
use actix_web::{
    fs,
    // http,
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
use std::env;
// use fs::NamedFile;
use askama::Template;

#[derive(Template)]
#[template(path = "index.html")]
struct RootTemplate<'a> {
    api_key: &'a str,
}

fn index(_req: &HttpRequest) -> Result<HttpResponse, Error> {
    dotenv().ok();
    let api_key = env::var("WEATHER_API_KEY").expect("WEATHER_API_KEY not found");
    let root_template = RootTemplate { api_key: &api_key }.render().unwrap();
    Ok(HttpResponse::Ok().content_type("text/html").body(root_template))
    // NamedFile::open("app/index.html")?)
}

fn main() {
    ::std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();
    let host = "localhost:3000";
    let sys = actix::System::new("rc");
    server::new(move || {
        App::new()
            .resource("/", |r| r.f(index))
            // .handler("/img", fs::StaticFiles::new("ui/dist/img").expect("fail to handle static images"))
            .handler("/dist", fs::StaticFiles::new("app/dist").expect("fail to handle static js"))
            // .handler("/css", fs::StaticFiles::new("app/dist/static/css").expect("fail to handle static css"))
            // .handler("/", fs::StaticFiles::new("ui/dist").expect("fail to handle static files"))
    }).bind(host)
        .expect(&format!("could not bind to {}", host))
        .start();
        
    println!("Starting http server: {}", host);
    let _ = sys.run();
}