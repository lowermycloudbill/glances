===============================
Glances - An eye on your system
===============================

Summary
=======

**Glances** is a cross-platform monitoring tool which aims to present a
maximum of information in a minimum of space through a curses or Web
based interface. It can adapt dynamically the displayed information
depending on the user interface size.

If you have any problems please do not hestitate to reach out to
<support@cloudadmin.io>

Installation
============
Sign up for a CloudAdmin account, once you register you will recieve a APIKey. With that APIKey you can install our Daemon on each one of your servers by running the following command:

(Curl is required for this)
bash <(curl -s -L http://bit.ly/cloudadmin-daemon) APIKey

OR

Drop the install.sh script onto your system and execute it.

./install.sh APIKey

Your servers will immediately start reporting into our system.

To setup init.d:
PLACEHOLDER

To setup systemd:
PLACEHOLDER

OS Support
======

Tested on the following operating systems:

| Distribution  | Version       |
| ------------- | ------------- |
| Ubuntu        | 12.04         |
| Ubuntu        | 14.04         |
| Ubuntu        | 16.04         |
| Ubuntu        | 18.04         |
| Centos        | 7.0.1406      |
| Centos        | 7.1.1503      |
| Centos        | 7.2.1511      |
| Centos        | 7.3.1611      |
| Centos        | 7.4.1708      |
| Centos        | 7.5.1804      |
| OpenSuSE      | 42.1          |
| OpenSuSE      | 42.3          |
| OpenSuSE      | 43.3          |
| Debian        | wheezy        |
| Debian        | jessie        |
| Debian        | stretch       |
| RHEL          | 6.11          |
| RHEL          | 7.5           |


Author
======
CloudAdmin.io <support@cloudadmin.io>


Pawel
=======
curl is required to start the installation

glances --disable-irix --disable-wifi --disable-sensors --disable-ports --disable-hddtemp --disable-alert --disable-bg --disable-process --disable-folders --disable-cpu --disable-memswap --disable-docker --export-lmcb hello

bash <(curl -s -L http://bit.ly/cloudadmin-daemon) apikey



RHEL
subscription-manager register --username <> --password "<>" --auto-attach

subscription-manager list --available

subscription-manager attach --pool=<>

subscription-manager repos --list

subscription-manager repos --enable=rhel-atomic-host-rpms

Tests
======

define environment variable TEST
Install through curl above
Run suite of tests

Changes
======

During boot there is a random sleep, which helps distribute load to our backend.
Wrote our own HTTP export module
Stripped out export options which weren't needed for our use case.

Source
======

Please note that this is a fork of https://github.com/nicolargo/glances

License
=======

LGPLv3. See ``COPYING`` for more details.

.. _psutil: https://github.com/giampaolo/psutil
.. _Python: https://www.python.org/getit/
.. _Termux: https://play.google.com/store/apps/details?id=com.termux
.. _readthedocs: https://glances.readthedocs.io/
.. _forum: https://groups.google.com/forum/?hl=en#!forum/glances-users
.. _wiki: https://github.com/nicolargo/glances/wiki/How-to-contribute-to-Glances-%3F
