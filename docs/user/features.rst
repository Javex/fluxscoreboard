Use-Case & Features
===================

Is This the Scoreboard I Am Looking For?
----------------------------------------

Absolutely (\*waves hand\*). Wait. It may be. Are you trying the run a jeopardy
style CTF? Then this *might* be right for you. Are you looking for an
enterprise-level firewall? Then this is not for you.

Seriously: If you want to host some kind of competition that has teams and
challenges and points and awesomeness then you might want to read on.

What Does It Do?
----------------

Here are some of the neat features it has to offer:

- Allows to set start and end time (which allows you three states: before,
  during and after).

  - Before: Teams can register and watch the list of registered teams. They can 
    log in, edit their profile and stuff. However, the challenges and the design
    are hidden from them.
  - During: Teams can no longer register
    (See `#4 <https://github.com/Javex/fluxscoreboard/issues/4>`_). They can
    log in, watch the scoreboard (i.e. the other teams points and so on),
    view and solve challenges and generally play the CTF.
  - After: Registration is off. Login is off. Submitting challenge solutions
    is also off. The scoreboard is static and does not change anymore. The
    challenges can still be viewed.
- Archive Mode: Adds a fourth state: When the scoreboard is running in archive
  mode it is no longer possible to register or login. It behaves similar to
  the "After" mode but it allows solving challenges again. It then just notifes
  you if the solution was correct but does not persist this anywhere.
- Avatars: Teams can upload cool images. Beware of animated gifs :-)
- Mass Mail: Want to notify all participants about something? Send a mass mail
  to all of them. Warning: Teams cannot turn this off so be sure to use it only
  when really needed.
- Dynamic Challenges: You can write a challenge that does not work along the
  usual rules: Instead of having a static solution, you can control most parts
  of a challenge yourself. Theoretically, you could add multiple dynamic
  challenges at the same time but this has not really been tested. If you
  wanna create a dynamic challenge, take a look at :ref:`dynamic`.
- Track IPs of teams: Some suckers want to ruin your nice competition by
  breaking your rules and gaining an unfair advantage. The scoreboard tracks the
  IP of every participant and stores it for the team. If you notice someone breaking
  your rules on your challenges, you can look up the IP and get the team name.
  You can then easily deactivate/ban/warn/harass them. You can also get all known IPs
  for a team. After the CTF you could also use this for some kind of statistics
  (e.g. from how many countries your players joined in).
- Log in as any team: An administrator can log in as any team and view the page
  exactly as they do. This may help during debugging or assisting a team. Of course
  you should not abuse your power. This will not give you world domination anyway,
  wrong software for that.
- `Challenge Tokens`_: Identify a team by token to protect your challenge.
- Announcements/Hints: Support as well for global announcements as for hints for
  particular challenges.
- The rest is pretty basic: Registration, Administration, etc...

You like it? Go a ahead and `get started <getting_started>`_.

Feature Description
-------------------

Challenge Tokens
################

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
