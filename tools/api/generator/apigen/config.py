"""Constants for the freedict-API generator."""

import re

# don't use www.sourceforge.net since that is redirected to sourceforge.net
# anyway and results in a "HostChangedError"
PROJECTHOME_HOST = 'sourceforge.net'
# base on web server, used for the link generation
RELEASE_HTTP_BASE = '/projects/freedict/files/'


# pattern to identify dictionaries; matches three-digit ISO 6639 letter codes
DICTIONARY_PATTERN = re.compile(r'(?:freedict-)?([a-z]{3}-[a-z]{3}).*')

# Pattern to identify directory names of directories; matches English names of
# languages, separated by " - "
DICTIONARY_DIRECTORY_PATTERN = re.compile(r"[A-Z][a-z]+%20-%20[A-z][a-z]+")

# Identification of versions; basically distutils.version.StrictVersion, but
# permits "-" as separator, too
VERSION_PATTERN = re.compile(r"(\d+)(-|\.)(\d+)?(-|\.)?(\d+)?")

