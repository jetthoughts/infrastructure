#!/bin/bash

eval "$(jq -r '@sh "path=\(.foo)"')"
