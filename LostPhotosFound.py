#!/usr/bin/env python
# -*- coding: utf-8 -*-
# code is under GPLv2
# <caio1982@gmail.com>

# to save the images
import os

# to build the mail object and pickle fields
import email

# the working man (should we connect to IMAP as a read-only client btw?)
from imapclient import IMAPClient

HOST = 'imap.gmail.com'
USERNAME = 'username@gmail.com'
PASSWORD = 'password'
SSL = True

server = IMAPClient(HOST, use_uid=True, ssl=SSL)
server.login(USERNAME, PASSWORD)

server.select_folder('[Gmail]/All Mail')

# that's why we only support gmail
# for other mail services we'd have to translate the custom
# search to actual IMAP queries, thus no X-GM-RAW cookie to us
criteria = 'X-GM-RAW "has:attachment filename:(jpg OR jpeg OR gif OR png OR tiff OR tif OR ico OR xbm OR bmp)"'
messages = server.search([criteria])

# stats
print 'LOG: %d messages matched the search criteria %s' % (len(messages), criteria)

for m in messages:
    data = server.fetch([m], ['RFC822'])
    for d in data:
        # SEQ is also available
        mail = email.message_from_string(data[d]['RFC822'])
        if mail.get_content_maintype() != 'multipart':
            continue
        print "["+mail["From"]+"]: " + mail["Subject"]
        for part in mail.walk():
            if part.get_content_maintype() == 'multipart':
                continue
            if part.get('Content-Disposition') is None:
                continue
            filename = part.get_filename()
            seq = 1
            if not filename:
                filename = 'attachment-%03d%s' % (seq, 'bin')
                seq += 1
            saved = os.path.join('./', filename)
            if not os.path.isfile(saved) :
                f = open(saved, 'wb')
                f.write(part.get_payload(decode=True))
                f.close()

server.close_folder()
server.logout()