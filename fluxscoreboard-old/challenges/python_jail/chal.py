#!/usr/bin/env python
'''
Running instructions.
 sockets are insecure. We do not implement any socket behaviour in this
 file.
 Please make this file +x and run with socat:
    socat TCP-LISTEN:45454,fork EXEC:./chal.py,pty,stderr

Debugging:
 Just execute chal.py and play on terminal, no need to run socat

Note:
 This challenge is a tribute to PHDays Finals 2012 challenge 'ndevice'.
 Thanks again, I had fun solving it.
 
 I'm fairly certain that this challenge avoids being exploitable by
 the tricks we could use in PHDays (the module "os" was imported...).
 So, no advantage for people who did not attend PHDays.
 

'''

def make_secure():
        UNSAFE_BUILTINS = ['open',
         'file',
         'execfile',
         'compile',
	'reload',
	'__import__',
	'eval',
         'input'] ## block objet?
        for func in UNSAFE_BUILTINS:
                del __builtins__.__dict__[func]

from re import findall
make_secure()


print 'Go Ahead, Expoit me >;D'


while True:
    try:
	inp = findall('\S+', raw_input())[0]
	# idea for second flaw: use input() instead of raw_input()
	# --> input already does eval(), so we escape this regex filter
	a = None
	exec 'a=' + inp
	print 'Return Value:', a
    except Exception, e:
	print 'Exception:', e

	
