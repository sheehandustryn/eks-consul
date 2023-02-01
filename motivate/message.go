package main

import (
	"strconv"
	"time"
)

type message struct {
	MESSAGE   string `json:"message"`
	TIMESTAMP string `json:"timestamp"`
}

func createMessage() (message, error) {
	result := message{"Automate all the things!", strconv.FormatInt(time.Now().Unix(), 10)}

	return result, nil
}
