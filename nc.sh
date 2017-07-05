#!/bin/bash
#iperf3 server
#IPERFS="iperf3_server_address"
#Zabbix server
ZSERV="192.168.20.89"

set -o pipefail

NNC=`snmpwalk -v 2c -c public localhost iso.3.6.1.2.1.2.1 | awk '{print $4}'`
RAM=`snmpwalk -v 2c -c public localhost iso.3.6.1.4.1.2021.4.5.0 | awk '{print $4}'`
VCPUs=`snmpwalk -v 2c -c public localhost iso.3.6.1.4.1.2021.11.52.0 | awk '{print $4}'`
DISK=`snmpwalk -v 2c -c public localhost iso.3.6.1.4.1.2021.9.1.6.1 | awk '{print $4}'`
OS=`snmpwalk -v 2c -c public localhost iso.3.6.1.2.1.1.1 | awk '{ print $7}'`
#in case of iperf3 failure set measurement result to 0
#if [ "$?" -ne "0" ]; then
#    NNC=0
#fi

#echo "iperf3 server:"$IPERFS", Upload=" $ULOAD "Download=" $DLOAD

#THOST=`echo $HOSTNAME`
THOST=`echo $HOSTNAME`

#send the measurement results to items of Zabbix_trapper type.
if [ -n "$THOST" ]; then
    /usr/bin/zabbix_sender -z $ZSERV -p 10051 -s $THOST -k net.networkcard.count -o $NNC
    /usr/bin/zabbix_sender -z $ZSERV -p 10051 -s $THOST -k net.ram.count -o $RAM
    /usr/bin/zabbix_sender -z $ZSERV -p 10051 -s $THOST -k net.vcpu.count -o $VCPUs
    /usr/bin/zabbix_sender -z $ZSERV -p 10051 -s $THOST -k net.disk.count -o $DISK
    /usr/bin/zabbix_sender -z $ZSERV -p 10051 -s $THOST -k net.os.count -o $OS
  else
    echo "error"
fi

