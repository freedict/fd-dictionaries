"""This file provides classes to parse all dictionaries to extract the required
meta data for the freedict-database.xml. The meta data comes from the header of
each dictionary and gives details on the quality or size of a dictionary."""
import datetime
import html.parser
import io
import os
import re
from xml.etree import ElementTree as ET

import dictionary
import xmlhandlers
from xmlhandlers import istag

class MetaDataParser(xmlhandlers.TeiHeadParser):
    """Parse a TEI XML dictionary for required and optional meta data using
    Python's iterparse facility. It guesses the path on it's own, unless a path
    is given as optional parameter.  For each element where data should be
    extracted, there is a handle_<tagname> which is called if it exists.
    This is a common class from which concrete parserfs can be derived. They all
    share the facility to parse TEI XML, but they can differ in they way they
    retrieve the TEI XML. While the local file system is a natural choice,
    one could choose to retrieve the information over HTTP(s).
    After the header has been parsed, the .dictionary attribute holds a reference
    to a populated Dictionary object."""
    # pattern to match mtaintainer in <resp/> tag
    MAINTAINER_PATTERN = re.compile(r'^([^<]+)\s*<?([^<]+)?>$')
    # match number of headwords in <extend/> pattern
    HEADWORD_PATTERN = re.compile(r'(\d+(?:\.|,|\s*)\d*).*')

    def __init__(self, name, xml):
        # can be a file object or a string with XML data
        xml = self.get_file_object(xml)
        super().__init__(xml)
        self.dictionary = dictionary.Dictionary(name)
        self.dictionary['date'] = None

    def get_file_object(self, src):
        """Transparently create a file object. If this method gets a file
        object, it will return is unchanged, otherwise the given string is
        wrapped in a StringIO object."""
        if hasattr(src, 'read') and hasattr(src, 'close'):
            return src # is already file object
        elif isinstance(src, bytes):
            return io.BytesIO(src)
        elif isinstance(src, str):
            return io.StringIO(src)
        else:
            raise ValueError("Either file object, str or byte array " + \
                    "expected, got %s." % type(src))

    def parse(self):
        try:
            super().parse()
        except ET.ParseError as e:
            print(("Warning: while parsing {} an error occured. Might be still "
                    "ok though.{}").format(self.dictionary.get_name(),
                        '; '.join(e.args)))

        # check whether parsing was successful
        if not self.dictionary.is_complete():
            missing = [k for k in self.dictionary.get_mandatory_keys()
                        if not self.dictionary[k]]
            raise ValueError("%s: the following information couldn't be read: "\
                % self.dictionary['name'] + ', '.join(missing))

    def handle_tag(self, elem):
        """Delegate parsing of XML elements."""
        if istag(elem, 'date') and not self.dictionary['date']:
            # take when attribute, is often in ISO 8601
            if elem.get('when'):
                self.dictionary['date'] = elem.get('when')
            else:
                self.dictionary['date'] = elem.text[:]
        elif istag(elem, 'revisionDesc') and not self.dictionary['date']:
            self.__handle_revisionDesc(elem)
        else: # call specialized tag handler function, if possible
            tag = elem.tag.split(self._namespace)[-1] # strip etree namespace
            funcname = 'handle_%s' % tag
            if not hasattr(self, funcname):
                return
            result = getattr(self, funcname)(elem)
            if result:
                self.dictionary.update(result)


    def handle_sourceDesc(self, node):
        """Extract a source url, if any."""
        ptr = node.findall(self._namespace + 'ptr')
        if not ptr: # search whether ptr is embedded in p tag
            for p in node:
                ptr = p.findall(self._namespace + 'ptr')
                if ptr:
                    return {'sourceURL': ptr[0].get('target')}
        else:
            return {'sourceURL': ptr.get('target')}

    def handle_edition(self, elem):
        return {'edition': elem.text[:]}


    def handle_notesStmt(self, node):
        """Try to extract status."""
        for note in node.findall(self._namespace + 'note'):
            if note.get('type') == 'status':
                return {'status': note.text}
        raise ValueError('A notesStmt without a <note type="status"/> encountered.')



    def handle_extent(self, elem):
        """Extract extent (number of headwords)."""
        match = MetaDataParser.HEADWORD_PATTERN.search(elem.text)
        if not match:
            raise ValueError("Could not extract number of headwords from " +
                    repr(elem.text))
        headwords = ''.join(char for char in match.groups()[0] if char.isdigit())
        return {'headwords': headwords}


    def handle_respStmt(self, respStmt):
        """Maintainer is in <respStmt/>, this one can contain nesting for author
        and maintainer, hide complexity and return either maintainer, then
        author or None."""
        # find name attribute
        name = respStmt.find(self._namespace + 'name')
        if name is None:
            return
        resp = respStmt.findall(self._namespace + 'resp')
        if resp is None or not any('maintainer' in t.text.lower() for t in resp):
            return
        maintainer = name.text
        if not maintainer:
            return
        if 'up for grab' in maintainer.lower(): # not a real maintainer
            return
        # try to extract email address:
        if '@' in maintainer:
            maintainer = html.parser.unescape(maintainer)
        match = self.MAINTAINER_PATTERN.search(maintainer)
        if match:
            return {'maintainerName': match.groups()[0].rstrip().lstrip(),
                    'maintainerEmail': match.groups()[1].rstrip().lstrip()
                   }
        else:
            return {'maintainerName': maintainer.rstrip().lstrip()}

    def __handle_revisionDesc(self, elem):
        """If date has not been set, try to guess it from revision desc."""
        lastchange = elem[0]
        if not lastchange.tag.endswith('change'):
            return # is not a change attribute, can't read any information
        if lastchange.get('when'):
            return lastchange.get('when')
        for child in elem:
            if child.tag.endswith('date'):
                return child.text

    def __format_date(self, date):
        """Bring date into the following format: YYYY-MM-dd."""
        if re.search(r"\d+-\d+-\d+", date):
            return date
        try:
            dateobj = datetime.datetime.strptime(date, "%d %B %Y")
            date = '%d-%d-%d' % (dateobj.year, dateobj.month, dateobj.day)
        except ValueError:
            pass

    def parse_dicts(self):
        raise TypeError("This class is not meant to be used directly.""")



class LocalMetaDataParser(MetaDataParser):
    """Parse meta data from XML dictionaries from a local fs path."""
    def __init__(self, name, xml):
        super().__init__(name, xml)

def get_meta_from_xml(path):
    """Parse meta data for all dictionaries in the FreeDict Root. Returns a list
    of Dictionary() objects."""
    dictionaries = []
    dict_pattern = re.compile(r'^[a-z]{3}-[a-z]{3}$')
    for item in os.listdir(path):
        full_path = os.path.join(path, item)
        matched = dict_pattern.search(item)
        if not matched: # eng-hun and hun-eng end on .header; auto-generated
            continue # is not a dictionary
        # append dictname.tei:
        full_path = os.path.join(full_path, item) + '.tei'
        if not os.path.exists(full_path):
            full_path += '.header'
        if not os.path.exists(full_path):
            raise FileNotFoundError("For dictionary %s no dictionary file was found." % item)
        with open(full_path, 'rb') as f:
            dparser = LocalMetaDataParser(item, f)
            dparser.parse()
            dictionaries.append(dparser.dictionary)
    return dictionaries


