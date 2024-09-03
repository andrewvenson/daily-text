#! /bin/zsh

action=$1
scripture=$2
text=$3

lua dailytext.lua $action $scripture $text
