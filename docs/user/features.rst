Features
========

Challenge Tokens
----------------

Challenge tokens are unique per team and can be used to identify a team against
a challenge. An example case would be if rate-limiting by team is desired. You
enable them in the admin backend on each challenge that needs a token by
setting the "Has Token" option.

Afterwards, the token will be displayed on the challenge description in the
frontend. The team will then send it to your challenge. From there you can
visit ``/verify_token/TOKEN`` where you replace ``TOKEN`` with the provided
token. You will receive a simple response: ``0`` if the token was invalid,
``1`` if it was valid. Currently, you need to manually look up tokens in the
database to find out to which team they belong to.
