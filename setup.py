#!/usr/bin/env python

import glob
import os
import re
import sys
from io import open

from setuptools import setup, Command


if sys.version_info < (2, 7) or (3, 0) <= sys.version_info < (3, 3):
    print('Glances requires at least Python 2.7 or 3.3 to run.')
    sys.exit(1)


# Global functions
##################

with open(os.path.join('glances', '__init__.py'), encoding='utf-8') as f:
    version = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", f.read(), re.M).group(1)

if not version:
    raise RuntimeError('Cannot find Glances version information.')


def get_data_files():
    data_files = [
        ('share/doc/glances', ['AUTHORS', 'COPYING', 'NEWS', 'README.md',
                               'CONTRIBUTING.md', 'conf/glances.conf'])
    ]

    return data_files


def get_install_requires():
    requires = ['psutil>=2.0.0', 'requests', 'netifaces']
    if sys.platform.startswith('win'):
        requires.append('bottle')

    return requires


class tests(Command):
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        import subprocess
        import sys
        for t in glob.glob('unitest.py'):
            ret = subprocess.call([sys.executable, t]) != 0
            if ret != 0:
                raise SystemExit(ret)
        raise SystemExit(0)


# Setup !

setup(
    name='Glances',
    version=version,
    description="A cross-platform curses-based monitoring tool",
    author='Nicolas Hennion',
    author_email='nicolas@nicolargo.com',
    url='https://github.com/nicolargo/glances',
    license='LGPLv3',
    keywords="cli curses monitoring system",
    install_requires=get_install_requires(),
    dependency_links = ['https://pypi.python.org/simple/requests', 'https://pypi.python.org/simple/psutil/', 'https://pypi.python.org/simple/netifaces/', 'https://pypi.python.org/simple/certifi/', 'https://pypi.python.org/simple/urllib3/', 'https://pypi.python.org/simple/idna/', 'https://pypi.python.org/simple/chardet/'],
    extras_require={
        'action': ['pystache'],
        'browser': ['zeroconf>=0.17'],
        'cloud': ['requests'],
        'cpuinfo': ['py-cpuinfo'],
        'chart': ['matplotlib'],
        'docker': ['docker>=2.0.0'],
        'export': ['http'],
        'gpu:python_version=="2.7"': ['nvidia-ml-py'],
        'ip': ['netifaces'],
        'raid': ['pymdstat'],
        'snmp': ['pysnmp'],
        'web': ['bottle', 'requests'],
        'wifi': ['wifi']
    },
    packages=['glances'],
    include_package_data=True,
    data_files=get_data_files(),
    cmdclass={'test': tests},
    test_suite="unitest.py",
    entry_points={"console_scripts": ["glances=glances:main"]},
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Environment :: Console :: Curses',
        'Environment :: Web Environment',
        'Framework :: Bottle',
        'Intended Audience :: Developers',
        'Intended Audience :: End Users/Desktop',
        'Intended Audience :: System Administrators',
        'License :: OSI Approved :: GNU Lesser General Public License v3 (LGPLv3)',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Topic :: System :: Monitoring'
    ]
)
