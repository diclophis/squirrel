#!/bin.sh

watch -n 0.1 'ps auxwwww | grep "risingcode" | grep -v grep | cut -d" " -f 20-100'
