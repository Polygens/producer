package creator

import (
	"github.com/gorilla/mux"
	"github.com/polygens/producer-api/config"
)

type App struct {
	router *mux.Router
	cfg    *config.Config
}

var app *App

// Init creates and starts the sensing
func Init(router *mux.Router, cfg *config.Config) {
	app = &App{router, cfg}

	app.setupRoutes()
}
