package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
)

var a App

func TestMain(m *testing.M) {
	a.Initialize()
	code := m.Run()
	os.Exit(code)
}

func executeRequest(req *http.Request) *httptest.ResponseRecorder {
	rr := httptest.NewRecorder()
	a.Router.ServeHTTP(rr, req)

	return rr
}

func checkResponseCode(t *testing.T, expected, actual int) {
	if expected != actual {
		t.Errorf("Expected response code %d. Got %d\n", expected, actual)
	}
}

func TestMotivateEndpoint(t *testing.T) {
	req, _ := http.NewRequest("GET", "/motivate", nil)
	response := executeRequest(req)

	checkResponseCode(t, http.StatusOK, response.Code)

	var m map[string]string

	json.Unmarshal(response.Body.Bytes(), &m)

	if m["message"] != "Automate all the things!" {
		t.Errorf("Expected message to equal 'Automate all the things!'. Got '%s'", m["message"])
	}

}
