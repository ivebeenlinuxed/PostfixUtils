#!/bin/bash

# Licenced under GPL v3 - Read at http://www.gnu.org/copyleft/gpl.html

# This script releases mail, so long as an HTTP script returns 1 when asked

MAILQ_BIN=/opt/zimbra/postfix/sbin/mailq
POSTSUPER_BIN=/opt/zimbra/postfix/sbin/postsuper
CHECKPAGE="http://[YOURIP]/yourtest.php" # Request appends "?email=asdf@asf.com". Should return "1" if mail should be released

I=0;
for FIELD in `$MAILQ_BIN | awk '{ print $1 }'`; do
	I=$I+1;	
#	echo "FIELD: $FIELD";
	EMAIL_TEST=$(echo $FIELD | grep -P "^[a-zA-Z0-9-.+_]+@");
	ID_TEST=$(echo $FIELD | grep -P "^[A-Z0-9*!]+$");
	
#	echo "ET: --$EMAIL_TEST-- "${#EMAIL_TEST};
#	echo "IT: --$ID_TEST-- "${#ID_TEST};

	#If we're an email address
	if [[ -n "$EMAIL_TEST" ]]; then
		EMAIL=$FIELD;
		echo "EMAIL: ${FIELD}";

		#If we're in the hold queue
		if [[ -n $(echo $MAILID | grep "!") ]]; then
			#Do your checks to 
			if [[ `wget -O - -q $CHECKPAGE?email=$EMAIL_TEST` -eq 1 ]]; then
				echo "RELEASE EMAIL";
				echo $MAILID | tr -d "*!" | $POSTSUPER_BIN -H -
			else
				echo "NON RELEASE";
			fi;
		else
			echo "Not a held message";
		fi;
	fi;

	#If we're a MailID
	if [[ -n "$ID_TEST" ]]; then
		MAILID=$FIELD;
		echo "ID: ${FIELD}";
	fi;
done;
