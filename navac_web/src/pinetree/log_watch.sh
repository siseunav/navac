#!/bin/bash


LOG_FILE=./app.log


echo "📡 로그 감시 시작: $LOG_FILE"

echo "-----------------------------"


tail -f $LOG_FILE
