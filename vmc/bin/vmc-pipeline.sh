#!/bin/sh

pipelinename=sl-pipeline-share-tripsocial
appname=sl-share-tripsocial
for environment in dev stg prd 
do
    heroku pipelines:remove -a ${appname}-${environment}
done

heroku pipelines:create -a ${appname}-dev ${pipelinename} --stage development 
heroku pipelines:add    -a ${appname}-stg ${pipelinename} --stage staging
heroku pipelines:add    -a ${appname}-prd ${pipelinename} --stage production 

