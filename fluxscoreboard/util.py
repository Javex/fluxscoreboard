# -*- coding: utf-8 -*-
from __future__ import unicode_literals, absolute_import, print_function
import bcrypt
import markupsafe
import string
import random


def encrypt_pw(pw, salt=None):
    """
    Encrypt a password (or any string) using bcrypt.

    Generate a salt and hash the given password with it. This string can then
    be stored in the database. Every time a user logs in, it has to be
    regenerated with the same salt.

    Function is deterministic if passing the same salt but random if
    no salt is passed (checking vs. generation)

    Args:
        ``pw``: A string with the password that should be encrypted.

        ``salt``: The salt used for hashing. This is only required if checking
        a password for validity, but not if encrypting a new one. A new
        password will have a fresh seed.

        .. warning::
            If passing in an arbitrary hash for a password that is new (not
            only used for a check) then no salt should be passed.

    Returns:
        The hashed password, complete with the generated (or passed) salt.
    """
    assert isinstance(pw, unicode)
    if salt is None:
        salt = bcrypt.gensalt()
    return unicode(bcrypt.hashpw(pw, salt))


def bcrypt_split(value):
    """
    Split up a bcrypt password into the salt and password part to be used
    with :func:`encrypt_pw`. Returns a tuple of ``(salt, pw)``.
    """
    return value[:29], value[29:]


def nl2br(text):
    text = unicode(markupsafe.escape(text))
    text = text.replace("\r\n", "\n")
    text = text.replace("\n", "<br />")
    return text


def random_str(len_, choice=string.ascii_letters):
    return "".join(random.choice(choice) for __ in xrange(len_))
