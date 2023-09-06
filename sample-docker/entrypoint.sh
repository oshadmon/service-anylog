#!/bin/bash

if [[ ! ${LICENSE_KEY} == "" ]] ; then
  python3.10  /app/start_anylog.py set license where activation_key=${LICENSE_KEY}
else
  python3.10  /app/start_anylog.py
fi