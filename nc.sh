#!/bin/bash
# https://www.zabbix.com/forum/showthread.php?t=45952
# Script for automated testing of internet connection bandwidth and
# registering of the results with the Zabbix server
#
# Copyright 2014, Janis Eisaks, Riga, LV
# All rights reserved.
#
#   Permission to use, copy, modify, and distribute this software for
#   any purpose with or without fee is hereby granted, provided that
#   the above copyright notice and this permission notice appear in all
#   copies.
#
#   THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
#   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#   MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#   IN NO EVENT SHALL THE AUTHORS AND COPYRIGHT HOLDERS AND THEIR
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
#   USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
#   OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   SUCH DAMAGE.
#
# Requirements: iperf3 (https://github.com/esnet/iperf)
#
# ATTENTION!!!
#
# THE HIGH LOAD OF THE INTERNET CONNECTION OVER 10 SECONDS PER MEASUREMENT
# (IF NOT MODIFIED) FOR BOTH iperf3 CLIENT AND SEVER HAS TO BE TAKEN INTO
# ACOOUNT!
# DO NOT SCHEDULE THE SCRIPT FOR EXECUTION TOO OFTEN AND/OR DURING BUSY HOURS!!!
#
# DO CONSIDER PLACEMENT OF iperf3 SERVER ON SEPARATE COMPUTER FROM ZABBIX
# SERVER AS IT MAY SIGNIFICANTLY INFLUENCE THE PERFORMANCE OF THE LATTER.
#
# In order to acquire UDP traffic bandwith parameters or for the use of
# input parameters differing from iperf3's defaults, script has to be modified
# accordingly.

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

