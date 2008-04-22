#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <glib.h>

// For XPath extension function(s)
#define FREEDICT_EDITOR_NAMESPACE "http://freedict.org/freedict-editor"
#define FREEDICT_EDITOR_NAMESPACE_PREFIX "fd"

// General XML/XPath utility functions
xmlDocPtr copy_node_to_doc(const xmlNodePtr node);
xmlNodePtr find_single_node(const char *xpath, const xmlDocPtr doc);
xmlNodeSetPtr find_node_set(const char *xpath, const xmlDocPtr doc, xmlXPathParserContextPtr *pctxt);
xmlNodePtr unlink_leaf_node_with_attr(const char *xpath,
    const char **attrs, const char **attr_contents,
    const xmlDocPtr doc, gboolean *can);
xmlNodePtr string2xmlNode(const xmlNodePtr parent, const char *before,
    const char *name, const char *content, const char *after);
gboolean entry_orths_to_string(xmlNodePtr n, int len, char *s);

