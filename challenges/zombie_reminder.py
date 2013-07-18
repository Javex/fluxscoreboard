# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from flask import Flask, request, make_response, redirect, url_for
from flask.helpers import flash, get_flashed_messages
from werkzeug.security import safe_str_cmp
import pickle, base64
b64e=base64.b64encode
b64d=base64.b64decode

SECRET_KEY=b'XiAqnj3ju81jyBtqHttbOGDoxsv9PYvIlHHzm9sLDMp22iGkaB'

cookie_secret=''

app = Flask(__name__)
app.config.from_object(__name__)

@app.route('/')
def home():
    base_str = """
    <html><head></head><body>
    %s
    %s
    <a href="/reminder">Remember brains!</a>
    </body></html>
    """
   
    remembered_str = '<p>Hello, here is what we remember for you. If you want to change, delete or extend it, click below.</p><p>%s</p>'
    new_str = '<p>Hello fellow zombie, have you found a tasty brain and want to remember where? Go right here and enter it:</p>'
   
    location = getlocation()
    if location == False:
        return redirect(url_for("clear"))
    elif location == '':
        rem_str = new_str
    else:
        rem_str = remembered_str % location
   
    flash_str = ''
    for msg in get_flashed_messages():
        flash_str += "%s<br />" % msg
    base_str = base_str % (flash_str, rem_str)
    return base_str
   
@app.route('/clear')
def clear():
    flash("Reminder cleared!")
    response = redirect(url_for('home'))
    response.set_cookie('location', max_age=0)
    return response

@app.route('/reminder', methods=['POST', 'GET'])
def reminder():
    if request.method == 'POST':
        location = request.form["reminder"]
        if location == '':
            flash("Message cleared, tell us when you have found more brains.")
        else:
            flash("We will remember where you find your brains.")
        location = b64e(pickle.dumps(location))
        cookie = make_cookie(location, cookie_secret)
        response = redirect(url_for('home'))
        response.set_cookie('location', cookie)
        return response
    location = getlocation()
    if location == False:
        return redirect(url_for("clear"))
    return """
    <html><head></head>
    <body>
        <p>Enter location of brains here:</p>
        <form method="POST" action="/reminder">
            <label>BRAINZ:</label><input type="text" name="reminder" value="%s"/><br />
            <input type="submit" name="submit" value="NOM!"/>
        </form>
    </body>
    </html>
    """ % location
   
def getlocation():
    cookie = request.cookies.get('location')
    if not cookie:
        return ''
    (digest, location) = cookie.split("!")
    if not safe_str_cmp(calc_digest(location, cookie_secret), digest):
        flash("Hey! This is not a valid cookie! Leave me alone.")
        return False
    location = pickle.loads(b64d(location))
    return location
       

def make_cookie(location, secret):
    return "%s!%s" % (calc_digest(location, secret), location)
   
   
def calc_digest(location, secret):
    from hashlib import sha256
    return sha256("%s%s" % (location, secret)).hexdigest()


def init_secret():
    from os import path
    import random, string
    if not path.exists('secret'):
        with open("secret", "w") as f:     
                secret = ''.join(random.choice(string.ascii_letters + string.digits) for x in range(5))
                f.write(secret)
    with open("secret", "r") as f:
        return f.read()


if __name__ == '__main__':
    cookie_secret = init_secret()
    app.run() 
