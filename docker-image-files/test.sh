#!/bin/bash

# default timeout is 60sec
export TIMEOUT=${TIMEOUT:-60}
export NETBOMB=${NETBOMB:-"iperf -c iperf.scottlinux.com -t ${TIMEOUT} -i 1 -p 5201 -u"}

export green='\e[0;32m'
export yellow='\e[0;33m'
export red='\e[0;31m'
export blue='\e[0;34m'
export endColor='\e[0m'

help() {
  echo -e "${red}WARNING: IT IS NOT GUARANTEED THAT YOUR SYSTEM/CONTAINERS WILL SURVIVE THIS KILLER TESTING! DO NOT USE THIS IMAGE UNLESS YOU REALLY KNOW WHAT ARE YOU DOING!${endColor}"
  echo -e "${yellow}Tests included in this image, such as: cpubomb, membomb, netbomb, forkbomb, ...${endColor}"
  echo -e "${yellow}Use 'all' or name of the particular test, e.g.:${endColor}" 
  echo -e "${yellow}docker run --rm -ti --privileged -v /:/rootfs --oom-kill-disable monitoringartist/docker-killer cpubomb${endColor}"
}
export -f help

forkbomb() {
  echo -e "${red}forkbomb - duration ${TIMEOUT}s${endColor}"
  echo -e "${yellow}Test: classic bash shell fork bomb${endColor}"
  :(){ :|:& };:
  # TODO
}
export -f forkbomb

cpubomb() {
  echo -e "${red}cpubomb - duration ${TIMEOUT}s${endColor}"
  echo -e "${yellow}Test: excessive CPU utilization - one proces per processor with empty cycles${endColor}"
  top -b -n${TIMEOUT} -d1 | grep "^CPU:" &
  #top -b -n${TIMEOUT} -d1 | grep "^Load average:" &      
  (
    pids=""
    cpus=$(getconf _NPROCESSORS_ONLN)
    trap 'for p in $pids; do kill $p; done' 0
    for ((i=0;i<cpus;i++)); do while : ; do : ; done & pids="$pids $!"; done
    sleep ${TIMEOUT}
  )
}
export -f cpubomb

membomb() {
  echo -e "${red}membomb - duration ${TIMEOUT}s${endColor}"
  echo -e "${yellow}Test: excessive memory utilization - bash variable with RAM+Swap size${endColor}"
  top -b -n${TIMEOUT} -d1 | grep "^Mem:" & 
  /membomb.bin
}
export -f membomb

netbomb() {
  echo -e "${red}netbomb - duration ${TIMEOUT}s${endColor}"
  echo -e "${yellow}Test: excessive network utilization - iperf against public iperf server${endColor}"  
  eval $NETBOMB
}
export -f netbomb

die() {
  echo -e "${red}die${endColor}"
  echo -e "${yellow}Test: exit container with exit code 1${endColor}"
  exit 1
}
export -f die

chaosmonkey() {
  echo -e "${red}chaosmonkey${endColor}"
  echo -e "${yellow}TODO Test: stop random running container${endColor}"
  # TODO
}
export -f chaosmonkey

passwords() {
  echo -e "${red}passwords${endColor}"
  echo -e "${yellow}TODO Test: read password hashes from the host system${endColor}"
  # TODO
}
export -f passwords

kernelpanic() {
  echo -e "${red}kernelpanic${endColor}"
  echo -e "${yellow}Test: raise kernel panic${endColor}"
  echo c >/proc/sysrq-trigger
}
export -f kernelpanic

if [ "$1" == "all" ]; then
  timeout -t ${TIMEOUT} -s KILL bash -c cpubomb
  timeout -t ${TIMEOUT} -s KILL bash -c membomb
  timeout -t ${TIMEOUT} -s KILL bash -c netbomb
  timeout -t ${TIMEOUT} -s KILL bash -c forkbomb
else 
  timeout -t ${TIMEOUT} -s KILL bash -c $@
fi
