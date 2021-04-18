#!/bin/bash
#
# GET data from min-api.cryptocompare.com and send it to Kafka
# 

# these global variables can come from Environment variables
KAFKA_BOOTSTRAP=frx-kafka:9092
KAFKA_TOPIC=forex
cd /opt/bin

if [ $# -eq 0 ]
  then
    echo "Missing parameters. Usage example: ./crypto-scrape.sh BTC USD,EUR"
    exit
fi

CURR=$1
XCURR_CSV=$2
COIN_URL="https://min-api.cryptocompare.com/data/price?fsym=$CURR&tsyms=$XCURR_CSV"

RESULT=`curl $COIN_URL`
echo "$CURR | $XCURR_CSV | $RESULT "
# example for BTC -> {"USD":62781.8,"EUR":52487.99}

CURRENT_TS=`date +%s`

XCURR=NA

for XCURR in `echo  $XCURR_CSV | tr , \  `
do
  PRICE=0.0
  #this could be replaced by regexp
  for PRICE_PAIR_STR in `echo $RESULT |  tr {} \  | tr , \ `
  do
     # PRICE_PAIR_STR looks like this ->   "USD":62781.8  and  filtered by just the current XCURR value
     if [ "`echo $PRICE_PAIR_STR | grep $XCURR`" != "" ]; then
       PRICE=`echo $PRICE_PAIR_STR | cut -d: -f2` 
     fi
  done
  echo $XCURR $PRICE
  MESSAGE_TEMPLATE="{\"schema\":{\"type\":\"struct\",\"fields\":[{\"field\":\"timestamp\",\"optional\":false,\"type\":\"int64\"},{\"field\":\"curr\",\"optional\":false,\"type\":\"string\"},{\"field\":\"xcurr\",\"optional\":false,\"type\":\"string\"},{\"field\":\"price\",\"optional\":false,\"type\":\"double\"}],\"optional\":false,\"name\":\"forex\"},\"payload\":{\"timestamp\":$CURRENT_TS,\"curr\":\"$CURR\",\"xcurr\":\"$XCURR\",\"price\":$PRICE}}"
  if [ "$PRICE" != "0.0" ]; then
    echo $MESSAGE_TEMPLATE | /opt/bin/kafka-console-producer.sh --broker-list $KAFKA_BOOTSTRAP --topic $KAFKA_TOPIC
  fi
done
