"""This module holds datastructures to represent a dictionary and links to their
downloads and a few function to retrieve useful information about these
objects."""
import datetime
import distutils.version
import enum
import os
import re
import urllib.request

from . import config

def extract_version(string):
    """Try to extract a version from the given string and feed it into
    distutils.version.StrictVersion, which is returned. If no version could be
    extracted, a ValueError is raised.
    If the given parameter is a path, only the last chunk, "base name", is
    used."""
    if os.sep in string: # it's a path
        string = os.path.basename(string.rstrip(os.sep))
    match = config.VERSION_PATTERN.search(string)
    if not match:
        raise ValueError("%s doesn't contain a version number to extract" %
                string)

    # remove None groups and join the fragments together with a dot to make
    # StrictVersion happy
    match = ''.join([m for m in match.groups() if m is not None])
    if match.endswith('.'): # strip trailing dots
        match = match.rstrip('.').lstrip('.')
    return distutils.version.LooseVersion(match)


class Dictionary:
    """Dictionary class holding various properties of a dictionary.
    This class is intended to hold all properties of a Dictionary node in the
    resulting XML API file.

    A dictionary object consists of optional and mandatory information:

    mandatory: headwords, edition, date
    optional = maintainerName, maintainerEmail, status, sourceURL

    The date should be the date of the last release.
    Additionally, a dictionary keeps a list of downloads which may be empty.
    Each download has to be a Link() object.
    """
    def __init__(self, name):
        self.__name = name
        # mandatory dictionary information
        mandatory = ['headwords', 'edition', 'date']
        self.__mandatory = dict([(f, None) for f in mandatory])
        # optional dictionary info
        self.__optional = {f: None for f in ['maintainerName',
            'maintainerEmail', 'status', 'sourceURL']}
        self.__downloads = []

    def get_name(self):
        """Return name of dictionary. This is a three-letter-code followed by a
        hypen and followed by a three-letter-code.
        Example: deu-fra"""
        return self.__name

    def add_download(self, link):
        """Add a link (of type Link) to the linst of downloadss."""
        if not isinstance(link, Link):
            raise TypeError("Link must be of type Link()")
        self.__downloads.append(link)

    def get_downloads(self):
        """Return all download links."""
        return self.__downloads


    def __getitem__(self, key):
        """Transparently select a key from either optional or mandatory keys."""
        if key in self.__mandatory:
            return self.__mandatory[key]
        elif key in self.__optional:
            return self.__optional[key]
        else:
            raise KeyError(key)

    def __contains__(self, key):
        try:
            self.__getitem__(key)
        except KeyError:
            return False
        else:
            return True

    def __setitem__(self, key, value):
        if key in self.__mandatory:
            self.__mandatory[key] = value
        elif key in self.__optional:
            self.__optional[key] = value
        else:
            raise KeyError(key)

    def get_mandatory_keys(self):
        """Return all mandatory keys."""
        return self.__mandatory.keys()

    def is_complete(self):
        """Return true if all mandatory fields are set, else false."""
        return not self._get_missing_keys()

    def _get_missing_keys(self):
        """Return list of keys which haven't been set yet but which are
        mandatory. Empty list means everything has been set."""
        return [k for k in self.__mandatory  if self.__mandatory[k] is None]


    def update(self, other):
        """This method works like the .update method on a dictionary, but it
        raises an exception whenever an unknown key is found in the supplied
        dictionary."""
        if not hasattr(other, '__getitem__') or not hasattr(other, 'keys'):
            raise TypeError("Object must provide methods keys() and __getitem__.")
        for key in other.keys():
            self[key] = other[key]

    def get_attributes(self):
        """Return all attributes which make up the dictionary node in the
        FreeDict XML. If mandatory attributes are not set, this function WILL
        NOT raise an exception, consequently, is_complete() must be called
        beforehand. Unset values are None.
        Hint: the name is not contained, use get_name() instead."""
        attributes = self.__mandatory.copy()
        attributes.update(self.__optional)
        return attributes
class DownloadFormat(enum.Enum):
    # match a version - should not be publicly visible
    # only match x.x, x.x.x, x-y-z, x-z
    __VERSION = r'(\d+(?:-|\.)\d+(?:-|\.)?\d*)'
    __DICTIONARY = '([a-z]{3}-[a-z]{3})'
    Source = re.compile(r"freedict-%s-%s.src.(?:zip|tar.bz2|tar.gz)" % (__DICTIONARY, __VERSION))
    DictTgz = re.compile(r"freedict-%s-%s.tar.gz" % (__DICTIONARY, __VERSION))
    DictBz2 = re.compile(r"freedict-%s-%s.tar.bz2" % (__DICTIONARY, __VERSION))

    @staticmethod
    def get_type(file_name):
        #pylint: disable=redefined-variable-type
        """This function allows to get the correct enum value from a given
        file_name. The file name is parsed and the corresponding enum value
        returned. If the format could not be extracted, None is returned."""
        format = DownloadFormat.Source
        if not DownloadFormat.Source.value.search(file_name):
            format = DownloadFormat.DictTgz
            if not DownloadFormat.DictTgz.value.search(file_name):
                format = DownloadFormat.DictBz2
                if not DownloadFormat.DictBz2.value.search(file_name):
                    return None
        return format

    def __str__(self):
        """Return a string representation of the enum value, as used in the type
        attribute of the release tag in the FreeDict XML API."""
        if self is DownloadFormat.Source:
            return 'src'
        elif self is DownloadFormat.DictTgz:
            return 'dict-tgz'
        elif self is DownloadFormat.DictBz2:
            return 'dict-bz2'
        else:
            raise ValueError("Unsupported format: " + self.name)


class Link:
    """Represent a (download) link.
    
    The link is made of of multiple parts. The hostname and base URI is taken
    from variables defined in the module config.
    The given path is assumed to exist on disk, so that the file can be
    determined.
    Additionally to the given link path, a link also saves the information about
    the file format (dict-bz2 or source) and also the version of the
    dictionary."""
    def __init__(self, path, format, version):
        self.path = path
        self.format = format
        self.version = version
        self.size = -1
        self.last_modification_date = 'NONE' # YYYY-MM-dd

    def __str__(self):
        """Get a download link."""
        # split the path into chunks, url-quote them
        path = tuple(map(urllib.request.quote, self.path.split(os.sep)))
        if len(path) < 3:
            raise ValueError("Required is a path with the structure LongName/version/filename")
        return 'https://{}{}{}/{}/{}/download'.format(config.PROJECTHOME_HOST,
                config.RELEASE_HTTP_BASE, path[-3], path[-2], path[-1])

def mklink(full_path, format, version):
    """Create a Link object with all the required information, i.e. file size.
    It queries the referenced `full_path` for its size and last modification
    date. It doesn't care whether it's actually on the file system or mounted
    with e.g. sshfs."""
    chunks = full_path.split(os.sep)
    path = '{}/{}/{}'.format(chunks[-3], chunks[-2], chunks[-1])
    link = Link(path, format, version)
    # get file size
    link.size = os.path.getsize(full_path)
    # get last modification date
    link.last_modification_date = datetime.datetime.fromtimestamp(
            os.path.getmtime(full_path)).strftime('%Y-%m-%d')
    return link


