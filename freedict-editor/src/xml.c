#include "xml.h"
#include <gnome.h>


xmlDocPtr copy_node_to_doc(const xmlNodePtr node)
{
  g_return_if_fail(node);
  xmlDocPtr doc = xmlNewDoc(XML_DEFAULT_VERSION);
  xmlNodePtr root = xmlDocCopyNode(node, doc, 1);// copies recursively
  xmlDocSetRootElement(doc, root); 
  g_assert(doc);
  return doc;
}


xmlNodeSetPtr find_node_set(const char *xpath, const xmlDocPtr doc)
{
  xmlXPathContextPtr ctxt = xmlXPathNewContext(doc);
  if(!ctxt)
  {
    g_printerr(G_STRLOC ": No XPathContext!\n");
    return NULL;
  }
  
  xmlXPathObjectPtr xpobj = xmlXPathEvalExpression(xpath, ctxt);
  if(!xpobj)
  {
    g_printerr(G_STRLOC ": No XPathObject!\n");
    xmlXPathFreeContext(ctxt);
    return NULL;
  }

  if(!(xpobj->nodesetval))
  {
    g_printerr(G_STRLOC ": No nodeset!\n");
    xmlXPathFreeObject(xpobj);
    xmlXPathFreeContext(ctxt);
    return NULL;
  }
  
  if(!(xpobj->nodesetval->nodeNr))
  {
    //g_printerr("0 nodes!\n");
    xmlXPathFreeObject(xpobj);
    xmlXPathFreeContext(ctxt);
    return NULL;
  }

  xmlNodeSetPtr nodes = xmlMalloc(sizeof(xmlNodeSet));
  memcpy(nodes, xpobj->nodesetval, sizeof(xmlNodeSet));
 
  // the caller will have to free the NodeList
  return nodes; 
}


xmlNodePtr find_single_node(const char *xpath, const xmlDocPtr doc)
{
  xmlNodeSetPtr nodes = find_node_set(xpath, doc);
  if(!nodes) return NULL;
  if(nodes->nodeNr>1)
    g_printerr(G_STRLOC ": %i matching nodes (only 1 expected). Taking first.\n",
      nodes->nodeNr);
      
  xmlNodePtr bodyNode = *(nodes->nodeTab);
  xmlXPathFreeNodeSet(nodes);
  return bodyNode;
}


gboolean has_only_text_children(const xmlNodePtr n)
{
  g_return_val_if_fail(n, FALSE);
 
  // elements may not have attributes
  if((n->type==XML_ELEMENT_NODE) && (n->properties!=NULL)) return FALSE;
      
  xmlNodePtr n2 = n->children;
  while(n2)
  {
    if(!xmlNodeIsText(n2)) return FALSE;
    g_assert(n2->children == NULL);
    n2 = n2->next;
  }
  return TRUE;
}


// looks for a single node
// returns NULL if it was not found
// otherwise checks whether it is a leaf
// if it is a leaf, unlinks it and returns pointer to it
// if it is no leaf, no unlinking is done and can is set to FALSE
xmlNodePtr unlink_leaf_node(const char *xpath, const xmlDocPtr doc, gboolean *can)
{
  g_return_val_if_fail(xpath && doc && can, NULL);

  xmlNodePtr n = find_single_node(xpath, doc);
  if(n)
  {
    if(!has_only_text_children(n)) *can = FALSE;
    else xmlUnlinkNode(n);
  }
  return n;
}


xmlNodePtr string2xmlNode(const xmlNodePtr parent, const gchar *before,
    const gchar *name, const gchar *content, const gchar *after)
{
  g_return_if_fail(name);

  xmlNodeAddContent(parent, before); 
  xmlNodePtr newNode = xmlNewChild(parent, NULL, name, content);
  xmlNodeAddContent(parent, after); 

  return newNode;
}


// n: entry node
// len: size of *s in bytes
// s: pointer where result will be saved,
//    contains error string on failure
// returns success
gboolean entry_orths_to_string(xmlNodePtr n, int len, char *s)
{
  g_return_val_if_fail(n, FALSE);
  g_return_val_if_fail(s, FALSE);
  g_return_val_if_fail(n>0, FALSE);
  
  xmlDocPtr doc = copy_node_to_doc(n);

  // find the orth children of the current entry
  xmlNodeSetPtr set = find_node_set("/entry/form/orth", doc);
  
  if(!set || !set->nodeNr)
  {
    g_strlcpy(s, _("No nodes (form/orth)!"), len);
    xmlFreeDoc(doc);
    return FALSE;
  }

  // alloc temporary buffer
  // if glib offered g_utf8_strlcat(), we would not need
  // this buffer
  char *e = (char *) g_malloc(len);
  e[0] = '\0';

  int i;
  xmlNodePtr *n2;
  for(i=0, n2 = set->nodeTab; *n2 && i<set->nodeNr; n2++, i++)
  {
    xmlChar* content = xmlNodeGetContent(*n2);
    int l = strlen(e);
    if(l) g_strlcat(e, ", ", len);
    if(!content) g_strlcat(e, "(null)", len);
    else g_strlcat(e, content, len);
    if(content) xmlFree(content);
  }

  // copy again, caring for utf8 chars longer than 1 byte
  g_utf8_strncpy(s, e, len/2);

  g_free(e);
  xmlFreeDoc(doc);
  return TRUE;
}

