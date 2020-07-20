# sync-google-contacts

phone: impostazioni di installazione lingua italiana
phone: attivare modalità sviluppatore
phone: configurata rete WIFI
host:  editare il file Google-Syncevolution-Syncscript-Nexus5.sh , aggiornare username e password  , password per le app preventivamente creata in account google
adb:  adb push ./Google-Syncevolution-Syncscript-Nexus5.sh /home/phablet/Google-Syncevolution-Syncscript-Nexus5.sh
adb:  adb shell
adb:  chmod +x ./Google-Syncevolution-Syncscript-Nexus5.sh
adb:  bash -x ./Google-Syncevolution-Syncscript-Nexus5.sh
