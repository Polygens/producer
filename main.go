package main

import (
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	"github.com/gorilla/mux"
	log "github.com/sirupsen/logrus"

	"github.com/polygens/producer-api/config"
	creator "github.com/polygens/producer-api/producer"
)

var version string

func main() {
	log.Infof("Starting %s version: %s", filepath.Base(os.Args[0]), version)

	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %s", err)
	}

	logLvl, err := log.ParseLevel(cfg.LogLevel)
	if err != nil {
		log.Fatalf("Failed to set log level: %s", err)
	}

	log.SetLevel(logLvl)

	r := mux.NewRouter()

	creator.Init(r, cfg)

	log.Fatal(http.ListenAndServe(":"+strconv.Itoa(cfg.Port), r))
}
