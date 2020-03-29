package generator

import (
	"github.com/Shopify/sarama"
	"github.com/gorilla/mux"
	"github.com/polygens/producer/config"
)

// App contains the objects for the service
type App struct {
	router   *mux.Router
	config   *config.Config
	producer sarama.AsyncProducer
}

var app *App

// Init creates and starts the producer
func Init(r *mux.Router, cfg *config.Config) {
	app = &App{r, cfg, nil}

	app.setupRoutes()
	app.initKafka()

	go app.generateLocations()
}

// Close is used to handle a gracefull shutdown of the service
func Close() {
	app.producer.AsyncClose()
}
