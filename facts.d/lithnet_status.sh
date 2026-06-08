#!/bin/bash

# Apt is advertised as having an unstable command-line interface.  The format of /var/lib/dpkg/status seems stable and grep will return 0 on finding one or more matches, 1 for no matches. 
grep 'Package: lithnetaccessmanageragent' /var/lib/dpkg/status &> /dev/null

if [ $? != 0 ]
  then echo lithnet_agent=missing
  exit 0 # This bails us out of this facts script without bothering to run the rest of it
fi

# systemctl status returns 0 for running service, 4 for not running
systemctl status LithnetAccessManagerAgent &> /dev/null

if [ $? != 0 ]
  then echo lithnet_agent=installed_not_running
  exit 0
fi

# To get this far without falling into an exit 0, the service must be running.
echo lithnet_agent=running

