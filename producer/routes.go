package creator

import (
	"net/http"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func (app *App) setupRoutes() {
	app.router.Handle("/metrics", promhttp.Handler()).Methods("GET")
	app.router.HandleFunc("/ping", health).Methods("GET")
	app.router.HandleFunc("/ready", health).Methods("GET")
	app.router.HandleFunc("/live", health).Methods("GET")
}

func health(w http.ResponseWriter, request *http.Request) {
	w.WriteHeader(200)
	w.Write([]byte("pong"))
}
