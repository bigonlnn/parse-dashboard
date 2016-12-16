#!/bin/sh

npm install -g parse-dashboard
#parse-dashboard --appId trip-planner-on-heroku --masterKey master --serverURL "http://localhost:1337/parse" # local 
#parse-dashboard --appId trip-planner-on-heroku --masterKey master --serverURL "https://tripplanner-101.herokuapp.com/parse" # remote 
parse-dashboard --appId trip-planner-on-heroku --masterKey master --serverURL "https://sl-parse-server-dev.herokuapp.com/parse" 
