defmodule ApiServer.Router do
  use ApiServer.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["", "json", "application/json", "ttl", "application/x-turtle", "csv"]
    plug Corsica
    plug :allow_jsonp
  end

  scope "/api", ApiServer do
    pipe_through :api

    get "/", ApiController, :info
    get "/:theme", ApiController, :info

    get "/:theme/distinct", ApiController, :distinct
    get "/:theme/distinct/:service", ApiController, :distinct

    get "/:theme/sql", ApiController, :theme_sql
    get "/:theme/:service/:method", ApiController, :service
    get "/:_theme/:_service", ApiController, :service_direct

  end

  scope "/", ApiServer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/documentation", PageController, :docs
    get "/stream", PageController, :info

    get "/:theme", PageController, :theme
    get "/:theme/:service", PageController, :service
    get "/:theme/:service/docs", PageController, :service_docs
  end

end
