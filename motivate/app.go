package main

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
)

type App struct {
	Router *mux.Router
}

func (a *App) Initialize() {
	a.Router = mux.NewRouter()
	a.initializeRoutes()
}

func (a *App) Run(addr string) {
	http.ListenAndServe(":8080", a.Router)
}

func respondWithError(w http.ResponseWriter, code int, err_message string) {
	respondWithJSON(w, code, map[string]string{"error": err_message})
}

func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	response, _ := json.Marshal(payload)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write((response))
}

func (a *App) getMessage(w http.ResponseWriter, r *http.Request) {
	new_message, _ := createMessage()
	respondWithJSON(w, http.StatusOK, new_message)
}

func (a *App) initializeRoutes() {
	a.Router.HandleFunc("/motivate", a.getMessage).Methods("GET")
}
