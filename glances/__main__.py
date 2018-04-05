#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Glances - An eye on your system
#
# Copyright (C) 2017 Nicolargo <nicolas@nicolargo.com>
#
# Glances is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Glances is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""Allow user to run Glances as a module."""

# Execute with:
# $ python -m glances (2.7+)

import time
import random
import glances
import datetime

if __name__ == '__main__':
    # Problem: Imagine There are 1000 server called at the same time (same config on all instances).
    # Here we want to randomly slow down start program
    fh = open("/tmp/glances-debug", "w")
    server_start_interval = random.randint(0, 59)
    fh.write("before sleep" + datetime.datetime.now())
    fh.write("server_start_interval " + server_start_interval)
    time.sleep(server_start_interval)
    fh.write("after sleep" + datetime.datetime.now())
    fh.close()
    # End solution for problem
    glances.main()
