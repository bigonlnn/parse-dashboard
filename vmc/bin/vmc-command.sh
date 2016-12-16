#!/usr/bin/env bash

set -euo pipefail

declare -r SOURCE="${BASH_SOURCE[0]}"
declare -r DIR=$(dirname ${SOURCE})
declare -r VERSION=1

declare verbose=0
declare action='create'
declare env='local'
declare data='"version":"2016-02-04"'

declare CURL=$(which curl)

[ -z "${CURL}" ] && { echo "ERROR: missing curl. brew install curl"; exit 2; }

#CURL+=" --silent"

function usage() {
    cat <<END >&2
USAGE: $0 [-L|-l] [-a action]
        -a action      # action: create
        -e protocol:HOST:PORT   # environment end-point. name such as local, dev, qa, prod or URL. defaults to local
        -h|?           # usage
        -v             # verbose

eg,
    0$ -p com.verista.localmarket -u vclm://app/detail?itemid=123456 -n TripSocial -v -e local
    0$ -p com.verista.localmarket -u vclm://app/detail?itemid=123456 -n TripSocial -v -e http://shadowlife-share-tripsocial.herokuapp.com
END
    exit $1
}

function doCurl() {
    verb=$1
    url=$2
    data="${3:-}"
    [ ${verbose} -ne 0 ] &&
    echo "${CURL} --header \"Accept: application/json;charset=UTF-8\" --header \"Content-Type: application/json;charset=UTF-8\"  -d '${data}' -X ${verb} ${url} "
    ${CURL} --header "Accept: application/json;charset=UTF-8" --header "Content-Type: application/json;charset=UTF-8"  -d "${data}" -X ${verb} ${url}
    echo
}

function createApplinkFb() {
    data=$1
    doCurl POST ${BASE_URL}/v${VERSION}/applinkFb ${data}
    echo
    exit 0
}

while getopts "a:e:p:u:n:hv?" opt
do
    case ${opt} in
        a) action=${OPTARG};;
        e) env=${OPTARG};;
        p) data+=",\"android_package\":\"${OPTARG}\"";;
        u) data+=",\"android_url\":\"${OPTARG}\",\"ios_url\":\"${OPTARG}\"";;
        n) data+=",\"name\":\"${OPTARG}\"";;
        v) verbose=1;; #set -x;;
        h|?) usage 0;;
        *) usage 1;;
    esac
done

case ${env} in
    'local') BASE_URL='http://localhost:9999';;
    'dev') BASE_URL='http://shadowlife-share-tripsocial.herokuapp.com';;
    'qa') BASE_URL='http://shadowlife-share-tripsocial.herokuapp.com';;
    'stg') BASE_URL='http://shadowlife-share-tripsocial.herokuapp.com';;
    'prd') BASE_URL='http://shadowlife-share-tripsocial.herokuapp.com';;
    *) BASE_URL="${env}";;
esac

data="{$data}"

case ${action} in
    'create') createApplinkFb ${data};;
    *) echo "ERROR: unknown action: ${action}" >&2; exit 2;
esac
