#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <glib.h>

// XML utility functions
xmlDocPtr copy_node_to_doc(const xmlNodePtr node);
xmlNodePtr find_single_node(const char *xpath, const xmlDocPtr doc);
xmlNodeSetPtr find_node_set(const char *xpath, const xmlDocPtr doc);
gboolean has_only_text_children(const xmlNodePtr n);
xmlNodePtr unlink_leaf_node(const char *xpath, const xmlDocPtr doc,
    gboolean *can);
xmlNodePtr string2xmlNode(const xmlNodePtr parent, const char *before, const char *name,
    const char *content, const char *after);
gboolean entry_orths_to_string(xmlNodePtr n, int len, char *s);

