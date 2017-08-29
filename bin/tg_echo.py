#!/usr/bin/python

from sys import stdin
import argparse

import telebot

TOKEN = 'token'
CHAT_ID = 1

parser = argparse.ArgumentParser(description='Send notification to Telegram')
parser.add_argument('message', metavar='MESSAGE', type=str, nargs='*',
                    help='Message to send, might be split to multiple arguments')
parser.add_argument('--infile', nargs='?', type=argparse.FileType('r'),
                    default=stdin)
parser.add_argument('--parse', choices=['html', 'markdown'])
args = parser.parse_args()

bot = telebot.TeleBot(TOKEN)

if args.message:
    message = ' '.join(args.message)
else:
    message = ''.join(args.infile.readlines())

parse = args.parse or None

bot.send_message(CHAT_ID, message, parse_mode=parse)
