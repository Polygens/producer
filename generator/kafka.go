package generator

import (
	"github.com/Shopify/sarama"
	log "github.com/sirupsen/logrus"
)

func (app *App) initKafka() {
	config := sarama.NewConfig()
	config.Producer.Return.Successes = true
	config.ClientID = app.config.Kafka.ClientID

	var err error
	config.Version, err = sarama.ParseKafkaVersion(app.config.Kafka.Version)
	if err != nil {
		log.Fatalf("Invalid kafka version used: %s", err)
	}

	app.producer, err = sarama.NewAsyncProducer(app.config.Kafka.Brokers, config)
	if err != nil {
		log.Fatalf("Failed to create producer: %s", err)
	}

	go produce(app.producer)
}

func produce(producer sarama.AsyncProducer) {
	for {
		select {
		case result := <-producer.Successes():
			log.Debugf("Message sent: \"%s\" sent to partition %d at offset %d\n", result.Value, result.Partition, result.Offset)
		case err := <-producer.Errors():
			log.Errorf("Failed to produce message: ", err)
		}
	}
}
