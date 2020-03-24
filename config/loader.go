package config

import (
	"encoding/json"

	"github.com/go-playground/validator"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

//LoadConfig loads the configuration from defaults file
func LoadConfig() (*Config, error) {
	var config *Config

	viper.SetConfigName("defaults")
	viper.AddConfigPath(".")

	err := viper.ReadInConfig()
	if err != nil {
		return nil, err
	}

	viper.SetConfigName("config")
	viper.AddConfigPath("/etc/config/")

	err = viper.MergeInConfig()
	if _, ok := err.(viper.ConfigFileNotFoundError); ok {
		log.Warning(err)
	} else {
		return nil, err
	}

	err = viper.UnmarshalExact(&config)
	if err != nil {
		return nil, err
	}

	err = validateConfig(config)
	if err != nil {
		return nil, err
	}

	cfgJSON, err := json.Marshal(config)
	if err != nil {
		log.Errorf("Failed to marshall config: %s", err)
	} else {
		log.Infof("Using config: %s", string(cfgJSON))
	}

	return config, nil
}

func validateConfig(cfg *Config) error {
	var validate = validator.New()
	return validate.Struct(cfg)
}
