#!/usr/bin/env bash

config='../../config'
env=dev

function manageApp() {
  echo "${appname}"
}

function verifyName() {
    [ ${appname}_ == "_" ] && echo "ERROR: -n appname is mandatory" &&  usage 1;
    verifyEnvironment;

    ENVIRONMENT_DEV=${appname}-dev
    ENVIRONMENT_STG=${appname}-stg
    ENVIRONMENT_PRD=${appname}-prd

    [ ${environment}_ == "dev"_ ] && git checkout master && git checkout -B ${ENVIRONMENT_DEV} && git merge master
    [ ${environment}_ == "stg"_ ] && git checkout ${ENVIRONMENT_DEV} && git checkout -B ${ENVIRONMENT_STG} && git merge ${ENVIRONMENT_DEV}
    [ ${environment}_ == "prd"_ ] && git checkout ${ENVIRONMENT_STG} && git checkout -B ${ENVIRONMENT_PRD} && git merge ${ENVIRONMENT_STG}
    appname=${appname}-${environment}
}

function verifyEnvironment() {
    [ ${environment}_ == "_" ] && echo "ERROR: -e environment is mandatory" &&  usage 1;
}

function removeGitHeroku() {
  [ ${verbose}_ == "1"_ ] && echo "git remote remove heroku"
  git remote remove heroku
}

function addGitHeroku() {
  [ ${verbose}_ == "1"_ ] && echo "git remote add heroku https://git.heroku.com/${appname}.git"
  git remote add heroku https://git.heroku.com/${appname}.git
}

function deleteApp() {
  [ ${force}_ == "_" ] && heroku apps:delete ${appname}
  [ ${force}_ == "1"_ ] && heroku apps:delete ${appname} --confirm ${appname}
  echo; exit 0;
}

function createApp() {
  removeGitHeroku
  addGitHeroku
  heroku apps:create ${appname}
  pushCode
  echo; exit 0;
}

function pushCode() {
#  gpg $config/config.$environment.properties.gpg
#  properties=`paste -d -s $config/config.$environment.properties`
#  heroku config:set --app ${appname} $properties
#  rm $config/config.$environment.properties
  git push --force heroku ${appname}:master
}

function listApp() {
  heroku apps
  echo; exit 0;
}

function usage() {
    cat <<END >&2
USAGE: $0 -n appname [-a action] [-c ../../config] [-e dev|stg|prd]
        -a action      # action: create/delete/manage
        -h|?           # usage
        -v             # verbose

eg,
    $0 -n sl-dev-share-tripsocial -a manage
    $0 -n sl-dev-share-tripsocial -a delete
    $0 -n sl-dev-share-tripsocial -a create
    $0 -n sl-dev-share-tripsocial -a list
    $0 -n sl-dev-share-tripsocial -a git -g add -v

locally:
     FACEBOOK_ACCESS_TOKEN='accountid|accountkey' APP_LINKS_HOSTS='https://graph.faceboocom/app/app_link_hosts' java -jar target/share-service-0.0.1-SNAPSHOT.jar

END
    exit $1
}

while getopts "a:d:e:h:g:l:n:fv?" opt
do
  case ${opt} in
    a)  action=${OPTARG};;
    c)  config=${OPTARG};;
    e)  environment=${OPTARG};;
    g)  git_heroku=${OPTARG};;
    f)  force=1;;
    n)  appname=${OPTARG};;
    v)  verbose=1;;
    h|?) usage 0;;
    *) usage 1;;
  esac
done

case ${action} in
    'create')   verifyName; createApp;;
    'delete')   verifyName; deleteApp;;
    'push')     verifyName; pushCode;;
    'list')     listApp;;
    'manage')   manageApp;;
    'git')  
            verifyName;
            if [ ${git_heroku}_ == "add_" ]; then
                addGitHeroku
            elif [ ${git_heroku}_ == "remove_" ]; then
                removeGitHeroku
            else
                usage 1
            fi;;
    *) echo "ERROR: unknown action: ${action}" >&2; exit 2;
esac
