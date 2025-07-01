import feedparser
USERNAME="username@gmail.com"
PASSWORD="password"
newmails = int(feedparser.parse("https://" + USERNAME + ":" + PASSWORD + "@mail.google.com/gmail/feed/atom")["feed"]["fullcount"])
if newmails > 0: 
	print "New emails"
else: 
	print "No new emails"
	
