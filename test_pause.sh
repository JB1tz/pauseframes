#!/bin/sh

# change these to suit

IFACE=your_interface_name
SERVER=172.21.2.5
CLIENT=172.21.2.1
TESTNAME=$1
PFORMAT=.png # I usually use .svg or pdf
SPEED=100
OFFLOAD=off
PAUSE=off

N="netperf-wrapper -4 -x -H $CLIENT"
# N2="$N" # if you want to spend 5 minutes more running 5 different tests
N2=/bin/true

# You shouldn't need to change anything after this test

eth_setup() {
ethtool -K tso off # some devices don't let you do all this at once
ethtool -K gso off
ethtool -K gro off
ethtool -K tso off
ethtool -s advertise 0x008
sleep 2
ping -c 2 $CLIENT
}

# Test the defaults

eth_change() {
ethtool -s advertise 0x020 # gigE
sleep 2 # takes a sec to reset
ping -c 2 $CLIENT # make sure we're alive
}

run_tests() {
tcpdump -i $IFACE -w "$TESTNAME-${SPEED}Mbit-defaults" -s 128 &
$N -t "$TESTNAME-${SPEED}Mbit-defaults" -p all_scaled -o "rrul-$TESTNAME-${SPEED}mbit.$PFORMAT" rrul
$N -t "$TESTNAME-${SPEED}Mbit-defaults" -p all_scaled -o "rrul_be-$TESTNAME-${SPEED}mbit.$PFORMAT" rrul_be
$N2 -t "$TESTNAME-${SPEED}Mbit-defaults" -p totals -o "tcp_upload-$TESTNAME-${SPEED}mbit.$PFORMAT" tcp_upload
$N2 -t "$TESTNAME-${SPEED}Mbit-defaults" -p totals -o "tcp_download-$TESTNAME-${SPEED}mbit.$PFORMAT" tcp_download
$N2 -t "$TESTNAME-${SPEED}Mbit-defaults" -p totals -o "tcp_bidir-$TESTNAME-${SPEED}mbit.$PFORMAT" tcp_bidir
killall tcpdump
}

# Setup
eth_setup
run_tests

eth_change -s advertise 0x020 # gigE
run_tests

# turn off pause frames

eth_change # fixme turn on pause frames
run_tests


# turn 
