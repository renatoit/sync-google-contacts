#!/bin/bash
#This script is a draft combination of the script found at https://gist.github.com/bastos77/0c47a94dd0bf3e394f879c0ff42b7839
# This script is a draft combination of the script found at https://gist.github.com/tcarrondo
# It is what I have done to make it work for my nexus5 2 with UBports ubuntu touch 16.04 rc
# Combined by me: Sebastian Gallehr <sebastian@gallehr.de>
# Thanks to: Tiago Carrondo <tcarrondo@ubuntu.com>
# Thanks to: Romain Fluttaz <romain@botux.fr>
# Thanks to: Wayne Ward <info@wayneward.co.uk>
# Thanks to: Mitchell Reese <mitchell@curiouslegends.com.au>
# --------------- [ Server ] ---------------- #
USERNAME="xxxxxx@gmail.com"               # Utenza google
PASSWORD="****************"               # Password google per le app

# ----------------- [ Phone ] ----------------- #
CRON_FREQUENCY="hourly"        # I use "hourly"

export DBUS_SESSION_BUS_ADDRESS=$(ps -u phablet e | grep -Eo 'dbus-daemon.*address=unix:abstract=/tmp/dbus-[A-Za-z0-9]{10}' | tail -c35)

export CONTACT_URL=$(syncevolution --print-databases backend=carddav username=$USERNAME password=$PASSWORD syncURL=https://www.googleapis.com/.well-known/carddav | grep "Address Book" | cut -d "(" -f2 | cut -d ")" -f1)

#Create Peer
syncevolution --configure --template SyncEvolution keyring=no username=$USERNAME password=$PASSWORD syncURL=https://www.googleapis.com/.well-known/carddav target-config@cgoogle
#Create New Source
syncevolution --configure backend=evolution-contacts database=Personale @default pgoogle
#Add remote database
syncevolution --configure database=$CONTACT_URL backend=carddav target-config@cgoogle pgoogle
#Connect remote contact list with local databases
syncevolution --configure --template SyncEvolution_Client syncURL=local://@cgoogle cgoogle pgoogle
#Add local database to the source
syncevolution --configure sync=two-way backend=evolution-contacts database=Personale cgoogle pgoogle
#Start first sync
syncevolution --sync refresh-from-remote cgoogle pgoogle


CONTACT_URL="https://www.google.com/calendar/dav/$USERNAME/events"
#Create Peer
syncevolution --configure --template SyncEvolution keyring=no username=$USERNAME password=$PASSWORD syncURL=$CONTACT_URL target-config@googlec
#Create New Source
syncevolution --configure backend=evolution-calendar database=Personale @default googlecal
#Add remote database
syncevolution --configure database=$CONTACT_URL backend=caldav target-config@googlec googlecal
#Connect remote contact list with local databases
syncevolution --configure --template SyncEvolution_Client syncURL=local://@googlec googlec googlecal
#Add local database to the source
syncevolution --configure sync=two-way backend=evolution-calendar database=Personale googlec googlecal
#Start first sync
syncevolution --sync refresh-from-remote googlec googlecal


#Add Sync Cronjob
sudo mount / -o remount,rw
COMMAND_LINE="export DISPLAY=:0.0 && export DBUS_SESSION_BUS_ADDRESS=$(ps -u phablet e | grep -Eo 'dbus-daemon.*address=unix:abstract=/tmp/dbus-[A-Za-z0-9]{10}' | tail -c35) && /usr/bin/syncevolution cgoogle && /usr/bin/syncevolution googlec"
sudo touch /sbin/googlecontactsync
sudo chmod 666 /sbin/googlecontactsync
sudo echo "$COMMAND_LINE" > /sbin/googlecontactsync
sudo chmod 755 /sbin/googlecontactsync

CRON_LINE="@$CRON_FREQUENCY /sbin/googlecontactsync"
(crontab -u phablet -r;) # only if no other cronjob already exist in the crontab
(crontab -u phablet -l; echo "$CRON_LINE" ) | crontab -u phablet -
sudo mount / -o remount,ro
sudo service cron restart
