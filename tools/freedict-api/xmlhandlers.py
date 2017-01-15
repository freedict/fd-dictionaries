"""Everything concerned with XML processing and writing."""

from xml.etree import ElementTree as ET

class TeiHeadParser:
    """This parser uses a SAX parser to parse the header information of a TEI
    file, wrapping it in an easy-to-use interface only emitting completely
    parsed tags and aborting when a <body> tag is encountered.
    Whenever a tag is encountered, self.handle_tag(...) is called."""
    def __init__(self, input_file_object):
        self.__input = input_file_object
        # make name space available for derived classes
        self._namespace = None

    def parse(self):
        # get an iterable from XML
        context = iter(ET.iterparse(self.__input, events=("start", "end")))
        # get the root element
        _event, root = next(context)
        # extract namespace
        end = root.tag.find('}')
        if end > 0:
            self._namespace = root.tag[:end+1]

        for event, elem in context:
            if event == 'start':
                if elem.tag.endswith('body'):
                    break # do not parse body
                else: continue # skip node, not fully populated

            self.handle_tag(elem)

    def handle_tag(self, node):
        pass



def istag(elem, name):
    """Tag comparison ignoring xml namespaces."""
    return elem.tag.endswith(name)

def create_node(tag, attrs):
    """Create ET.Element node with specified tag and attributes."""
    e = ET.Element(tag)
    e.attrib = attrs.copy()
    return e


def create_child(parent, tag, attrs):
    """Create child node and attach to parent."""
    c = create_node(tag, attrs)
    parent.append(c)


def dictionary2xml(dictionary):
    """Return the ElementNode (ElementTree) representation of this dictionary.
    Raise ValueError if a mandatory field is missing"""
    if not dictionary.is_complete():
        raise ValueError("Not all mandatory keys set.")
    downloads = dictionary.get_downloads()
    attributes = {k: v  for k, v in dictionary.get_attributes().items()
            if not v is None}
    attributes['name'] = dictionary.get_name()
    # set maintainer if none present
    if 'maintainerName' not in dictionary or not dictionary['maintainerName']:
        attributes['maintainerName'] = 'FreeDict - no maintainer assigned'
    dictionary = create_node('dictionary', attributes)
    for download in downloads:
        attrib = {'platform': str(download.format),
                'size': str(download.size),
                'date': download.last_modification_date,
                'URL': str(download), 'version': str(download.version)
                }
        create_child(dictionary, 'release', attrib)
    return dictionary

def indent(elem, level=0, more_sibs=False):
    i = "\n"
    if level:
        i += (level-1) * '  '
    num_kids = len(elem)
    if num_kids:
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
            if level:
                elem.text += '  '
        count = 0
        for kid in elem:
            indent(kid, level+1, count < num_kids - 1)
            count += 1
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
            if more_sibs:
                elem.tail += '  '
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i
            if more_sibs:
                elem.tail += '  '

def write_freedict_database(path, dicts):
    """Write a freedict database to ''path``."""
    root = ET.Element('FreeDictDatabase')
    root.extend([dictionary2xml(n) for n in dicts])
    indent(root)
    tree = ET.ElementTree()
    #pylint: disable=protected-access
    tree._setroot(root)
    tree.write(path, encoding="utf-8", xml_declaration=True)

