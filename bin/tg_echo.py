#!/usr/bin/python

import telebot
from sys import argv

TOKEN = 'token'
CHAT_ID = 1

bot = telebot.TeleBot(TOKEN)
bot.send_message(CHAT_ID, argv[1])

