package config

// Config contains all the configuration variables for this service
type Config struct {
	LogLevel string `validate:"required"`
	HTTPPort uint16 `validate:"required"`
	Kafka    Kafka
}

// Kafka contains the config for kafka
type Kafka struct {
	Version             string   `validate:"required"`
	Brokers             []string `validate:"gt=0,dive,hostname_port"`
	ClientID            string   `validate:"lowercase,printascii"`
	LocationOutputTopic string   `validate:"required,lowercase,printascii"`
}
