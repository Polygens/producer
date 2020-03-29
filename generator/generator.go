package generator

import (
	"encoding/json"
	"math/rand"
	"time"

	"github.com/Pallinder/sillyname-go"
	"github.com/Shopify/sarama"
	"github.com/polygens/models/kafka/location"
	log "github.com/sirupsen/logrus"
)

// generateLocations generates random locations as a mock datasource
func (app *App) generateLocations() {
	for range time.Tick(time.Minute) {
		randomLocation := location.Location{
			Name:         sillyname.GenerateStupidName(),
			Location:     [2]float64{rand.Float64() * 50, rand.Float64() * 50},
			LocationType: location.Hotel,
		}

		data, err := json.Marshal(randomLocation)
		if err != nil {
			log.Errorf("Failed to marshall message: %s", err)
		}
		app.producer.Input() <- &sarama.ProducerMessage{Topic: app.config.Kafka.LocationOutputTopic, Key: sarama.StringEncoder("hotel.add"), Value: sarama.ByteEncoder(data)}
	}
}
