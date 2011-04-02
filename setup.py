#!/usr/bin/python

import setuptools

setuptools.setup(
    name='radiograph',
    version='0.0.1',
    packages = setuptools.find_packages(exclude=[]),
    install_requires = [
        'beautifulsoup >= 3.2',
        'django >= 1.2.3',
        'South >= 0.7.3',
        'pysolr >= 2.0',
        'python-magic'
        ]
    )


