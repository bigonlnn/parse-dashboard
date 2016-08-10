#!/bin/sh

npm install -g parse-dashboard
parse-dashboard --appId trip-planner-on-heroku --masterKey master --serverURL "http://localhost:1337/parse"
