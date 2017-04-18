# -*- coding: utf-8 -*-
#
# This file is part of Glances.
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

"""CSV interface class."""

import csv
import sys
import time
import json
import requests
import ConfigParser

from glances import __version__
from glances.compat import PY3, iterkeys, itervalues
from glances.logger import logger
from glances.exports.glances_export import GlancesExport

class Export(GlancesExport):

    """This class manages the CSV export module."""

    def __init__(self, config=None, args=None):
        """Init the CSV export IF."""
        super(Export, self).__init__(config=config, args=args)

        # CSV file name
        #self.http_endpoint = args.export_http
        self.version = __version__
        #parse our config file
        config = ConfigParser.RawConfigParser()
        config.read('/etc/lowermycloudbill/lowermycloudbill.conf')
        self.api_key = config.get('LowerMyCloudBill','APIKey')
        self.http_endpoint = config.get('LowerMyCloudBill','URL')
        #get instance specific information
        self.demi_code = config.get('CloudProvider','DemideCode')
        self.instance_id = config.get('CloudProvider','InstanceID')
        self.instance_type = config.get('CloudProvider','InstanceType')
        self.availability_zone = config.get('CloudProvider','AvailabilityZone')

        headers = {
          'apikey' : self.api_key,
          'host' : 'development-metrics.lowermycloudbill.com',
          'version' : self.version,
          'demi-code' : self.demi_code,
          'instance-id' : self.instance_id,
          'instance-type' : self.instance_type,
          'avilability-zone' : self.availability_zone
        }
        self.headers = headers

    def update(self, stats):
        """Update stats in the CSV output file."""
        # Get the stats
        all_stats = stats.getAllExports()
        plugins = stats.getAllPlugins()

        csv_data = [time.strftime('%Y-%m-%d %H:%M:%S')]
        data = {'ts' : time.strftime('%Y-%m-%d %H:%M:%S')}

        # Loop over available plugin
        for i, plugin in enumerate(plugins):
            if plugin in self.plugins_to_export():
                if isinstance(all_stats[i], list):
                    tmpStats = []
                    for stat in all_stats[i]:
                        # Others lines: stats
                        tmpStats += itervalues(stat)
                    data[plugin] = tmpStats
                elif isinstance(all_stats[i], dict):
                    # Others lines: stats
                    csv_data += itervalues(all_stats[i])
                    data[plugin] = all_stats[i]

        # Export to HTTP
        data['metadata'] = self.headers
        r = requests.post(self.http_endpoint, json=data, headers=self.headers)
