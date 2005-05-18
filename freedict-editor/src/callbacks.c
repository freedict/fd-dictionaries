#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gnome.h>
#include <libgtkhtml/gtkhtml.h>
#include <gconf/gconf-client.h> 

#include "callbacks.h"
#include "interface.h"
#include "support.h"
#include "utils.h"
#include "xml.h"
#include "entryedit.h"

// global variables
xmlDocPtr teidoc, entry_template_doc;
xmlNodePtr edited_entry;
xsltStylesheetPtr entry_stylesheet;
HtmlDocument *htdoc;
GtkWidget *fileselection1, *html_view, *propertybox;
GtkListStore *store;
GtkCellRenderer *renderer;
GtkTreeViewColumn *column;
GConfClient *gc_client;

char *stylesheetfn;// filename of tei2htm.xsl
const gchar *selected_filename;
int save_as_mode;
gboolean form_modified, file_modified;

GArray *senses;


// show XML dump
void dump_node(xmlNodePtr n)
{
  xmlBufferPtr buf = xmlBufferCreate();
  int ret2 = xmlNodeDump(buf, teidoc, n, 0, 1);
  if(ret2 != -1)
    g_printerr("%s\n", xmlBufferContent(buf));
  if(buf) xmlBufferFree(buf);
}


void myload(const char *filename)
{
  g_return_if_fail(filename);
  int subs = xmlSubstituteEntitiesDefault(1);
  //fprintf(stderr, "Substitution of external entities was %i.\n", subs);
  //int vali = xmlDoValidityCheckingDefaultValue;
  xmlDoValidityCheckingDefaultValue = 1;
  //fprintf(stderr, "Validity checking was %i.\n", vali);
  //int extd = xmlLoadExtDtdDefaultValue;
  //xmlLoadExtDtdDefaultValue = 1;
  //fprintf(stderr, "Load ext DTD was %i.\n", extd);

  xmlDocPtr d = xmlParseFile(filename);
  if(!d)
  {
    mystatus(_("Failed to load file!"));
    return;
  }
  
  setTeidoc(d);

  xmlXPathContextPtr ctxt = xmlXPathNewContext(teidoc);
  if(!ctxt) mystatus(_("No Context!"));
  else
  {
    xmlXPathObjectPtr xpobj =
      xmlXPathEvalExpression("count(/TEI.2//entry)", ctxt);
    if(!xpobj) mystatus(_("No XPathObject!"));
    else
    {
      mystatus(_("Entries: %2.0f"), xpobj->floatval);
      xmlXPathFreeObject(xpobj);
    }
    xmlXPathFreeContext(ctxt);
  }
  on_select_entry_changed(NULL, NULL);
}


void
on_new1_activate                       (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  myload(PACKAGE_DATA_DIR "/" PACKAGE "/la1-la2.template.tei");
  selected_filename = NULL;
  //setTeidoc(teidoc);// get the title reset
}


void
on_open1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  save_as_mode = 0;
  if(!fileselection1) fileselection1 = create_fileselection1();
  gtk_widget_show_all(fileselection1);
}


void
on_save1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  if(!selected_filename || !strlen(selected_filename))
    on_save_as1_activate(NULL, NULL);
  else mysave();
}


void
on_save_as1_activate                   (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  save_as_mode = 1;
  if(!fileselection1) fileselection1 = create_fileselection1();
  gtk_widget_show_all(fileselection1);
}


gboolean
on_app1_delete_event                   (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data)
{
  gboolean sure;

  if(!file_modified) sure = TRUE;
  else
  {
    sure = FALSE;
    GtkWidget *dialog = gtk_message_dialog_new(GTK_WINDOW(app1),
	GTK_DIALOG_MODAL | GTK_DIALOG_DESTROY_WITH_PARENT,
	GTK_MESSAGE_QUESTION,
	GTK_BUTTONS_YES_NO,
	_("File modified. Save?"));
    gtk_dialog_add_button(GTK_DIALOG(dialog),
	GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL);
    gint result = gtk_dialog_run (GTK_DIALOG (dialog));
    switch(result)
    {
      case GTK_RESPONSE_YES:
	on_save1_activate(NULL, NULL);
	sure = TRUE;
	break;
      case GTK_RESPONSE_NO:
	sure = TRUE;
	break;
      case GTK_RESPONSE_CANCEL:
	break;
      default:
	g_assert_not_reached();
	break;
    }
    gtk_widget_destroy(dialog);
  }

  if(sure)
  {
    if(fileselection1) gtk_widget_destroy(fileselection1);
    gtk_main_quit();
    if(entry_stylesheet) xsltFreeStylesheet(entry_stylesheet);
    if(stylesheetfn) g_free(stylesheetfn);
    if(teidoc) xmlFreeDoc(teidoc);
    xsltCleanupGlobals();
    xmlCleanupParser();
    return FALSE;
  }

  return TRUE;
}




void
on_quit1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  on_app1_delete_event(NULL, NULL, NULL);
}


void
on_cut1_activate                       (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{

}


void
on_copy1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{

}


void
on_paste1_activate                     (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{

}


void
on_clear1_activate                     (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{

}


void
on_about1_activate                     (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  GtkWidget* about2 = create_about2();
  gtk_widget_show_all(about2);
}


void
on_openbutton_clicked                  (GtkButton       *button,
                                        gpointer         user_data)
{
  // show file selection dialog
  save_as_mode = 0;
  if(!fileselection1) fileselection1 = create_fileselection1();
  gtk_widget_show_all(fileselection1);
}


// the ok button of the file selection dialog is meant here
void
on_ok_button1_clicked                  (GtkButton       *button,
                                        gpointer         user_data)
{
  selected_filename = gtk_file_selection_get_filename(
    GTK_FILE_SELECTION(fileselection1));
  gtk_widget_hide(fileselection1);

  if(save_as_mode)
  {
    save_as_mode = 0;
    mysave();
    return;
  }

  myload(selected_filename);
}


// the cancel button of the file selection dialog is meant here
void
on_cancel_button1_clicked              (GtkButton       *button,
                                        gpointer         user_data)
{
  save_as_mode = 0;
  gtk_widget_hide(fileselection1);
}


// sets the global GTK+ IM,
// returns success
gboolean set_global_im_gtk_context_id(char *new_context_id)
{
   GtkEntry *e = GTK_ENTRY(lookup_widget(app1, "entry2"));
  // bad, since actually im_context is private!
  GtkIMMulticontext *m = GTK_IM_MULTICONTEXT(e->im_context);

  GtkWidget *dummymenu = gtk_menu_new();
  gtk_im_multicontext_append_menuitems (m, GTK_MENU_SHELL(dummymenu));

  gboolean success = FALSE;

  void mycallback(GtkWidget *widget, gpointer data)
  {
    char *context_id = (char *) g_object_get_data(G_OBJECT(widget), "gtk-context-id");

    if(strcmp(context_id, new_context_id)) return;

    // requested context id found
    gtk_menu_item_activate(GTK_MENU_ITEM(widget));
    success = TRUE;
  }
    
  gtk_container_foreach(GTK_CONTAINER(dummymenu), &mycallback, NULL);
  
  gtk_widget_destroy(dummymenu);
  return success;
}


char *find_global_im_gtk_context_id(void)
{
  GtkEntry *e = GTK_ENTRY(lookup_widget(app1, "entry2"));
  // bad, since actually im_context is private!
  GtkIMMulticontext *m = GTK_IM_MULTICONTEXT(e->im_context);

  GtkWidget *dummymenu = gtk_menu_new();
  gtk_im_multicontext_append_menuitems (m, GTK_MENU_SHELL(dummymenu));

  char *gtk_context_id = NULL;
  
  void mycallback(GtkWidget *widget, gpointer data)
  {
    char *context_id = (char *) g_object_get_data(G_OBJECT(widget), "gtk-context-id");
    //printf("cid='%s' ", context_id);
    
    //GtkWidget *c = gtk_bin_get_child(GTK_BIN(widget));
    //if(GTK_IS_LABEL(c))
    //  printf("label='%s'\n", gtk_label_get_text(GTK_LABEL(c)));
    
    if(!gtk_check_menu_item_get_active(GTK_CHECK_MENU_ITEM(widget))) return;
    
    // global context id found
    gtk_context_id = context_id;
 }
  
  gtk_container_foreach(GTK_CONTAINER(dummymenu), &mycallback, NULL);
  
  gtk_widget_destroy(dummymenu);
  return gtk_context_id;
}

// this doesn't belong here
//GtkEntry *e = GTK_ENTRY(lookup_widget(app1, "entry2"));
//GtkIMMulticontext *m = GTK_IM_MULTICONTEXT(e->im_context);
// strangely, the following always prints gtk-im-context-simple, ie.  reports
// the default IM would be used - which is not true!
//if(m) printf("e->im_context->context_id: %s\n", m->context_id);
// We want the global_context_id, which is static in
// gtk/gtkimmulticontext.c unfortunately, so we cannot access it.
  
// I wish GTK had the notion of local input methods.

void
on_select_entry_changed                (GtkEditable     *editable,
                                        gpointer         user_data)
{
  if(!store)
  {
    store = gtk_list_store_new(2, G_TYPE_STRING, G_TYPE_POINTER);
    gtk_tree_view_set_model(GTK_TREE_VIEW(lookup_widget(app1, "treeview1")),
	GTK_TREE_MODEL(store));
  }
  else gtk_list_store_clear(store);

  const gchar* select1 = gtk_entry_get_text(GTK_ENTRY(
	lookup_widget(app1, "select_entry")));
    
  // XXX for the FreeDict-Editor documentation: %% is escape for a % sign
  const gchar* select2 = gtk_entry_get_text(GTK_ENTRY(
	lookup_widget(app1, "xpath_entry")));

  char select[400];

  // format string check: only one %s and many %% allowed
  const char *fscan = select2;
  int scount = 0;
  while(*fscan)
  {
    char *perc = strchr(fscan, '%');
    if(!perc) break;
    switch(*(perc+1))
    {
      case 's':
	scount++;
	if(scount>1)
	{
	  mystatus(_("Malformed XPath-Template. Only one %%s and "
		"many %%%% allowed."));
	  return;
	}
      case '%':
	fscan = perc+2;
	continue;
      default:
	mystatus(_("Malformed XPath-Template. Only one %%s and "
	      "many %%%% allowed."));
	return;
    }
  }

  g_snprintf(select, sizeof(select), select2, select1);

  xmlNodeSetPtr nodes = find_node_set(select, teidoc);
  if(!nodes || !nodes->nodeNr) mystatus(_("No matches."));
  else
  {
    mystatus(_("%i matching nodes"), nodes->nodeNr);

    GtkTreeIter i;
    xmlNodePtr *n, *n2;
    int j = 0;
    for(n = nodes->nodeTab; *n && j<nodes->nodeNr && j<50; n++, j++)
    {
      char orthline[200];
      entry_orths_to_string(*n, sizeof(orthline), orthline);
      gtk_list_store_append(store, &i);
      gtk_list_store_set(store, &i, 0, orthline, 1, *n, -1);
    }

  }

  if(renderer) return;

  renderer = gtk_cell_renderer_text_new();
  column = gtk_tree_view_column_new_with_attributes("Matching Nodes",
      renderer, "text", 0, NULL);
  gtk_tree_view_append_column(GTK_TREE_VIEW(
	lookup_widget(app1, "treeview1")), column);
}


// opens the entry whose row was double-clicked in treeview1 for editing
void
on_treeview1_row_activated             (GtkTreeView     *treeview,
                                        GtkTreePath     *path,
                                        GtkTreeViewColumn *column,
                                        gpointer         user_data)
{
  GtkTreeIter iter;
  gboolean ret = gtk_tree_model_get_iter(GTK_TREE_MODEL(store), &iter, path);
  g_assert(ret);
  xmlNodePtr e;
  gtk_tree_model_get(GTK_TREE_MODEL(store), &iter, 1, &e, -1);
  set_edited_entry(e);
}


void replace_edited_entry(xmlNodePtr new_entry)
{
  g_return_if_fail(new_entry);
  g_return_if_fail(edited_entry);
  
  // replace old entry element in teidoc
  xmlReplaceNode(edited_entry, new_entry);
      
  xmlFree(edited_entry);
  if(!file_modified)
  { file_modified = TRUE; on_file_modified_changed(); }

  set_edited_entry(new_entry);
  g_assert(edited_entry == new_entry);

  // update treeview1
  on_select_entry_changed(NULL, NULL);
  
  mystatus(_("Edited entry accepted."));
}


// returns success
gboolean save_textview1()
{
  GtkTextView *textview1 = GTK_TEXT_VIEW(lookup_widget(app1, "textview1"));
  GtkTextBuffer* b = gtk_text_view_get_buffer(textview1);
  if(!gtk_text_buffer_get_modified(b)) return TRUE;
  
  // fetch edited XML text
  GtkTextIter start, end;
  gtk_text_buffer_get_start_iter(b,  &start);
  gtk_text_buffer_get_end_iter(b, &end);
  gchar* txt = gtk_text_buffer_get_text(b, &start, &end, FALSE);    

  // parse it
  xmlDoValidityCheckingDefaultValue = 0;
  
  //int subs = xmlSubstituteEntitiesDefault(0);
  //fprintf(stderr, "Substitution of external entities was %i.\n", subs);
  
  //int extd = xmlLoadExtDtdDefaultValue;
  //xmlLoadExtDtdDefaultValue = 1;
  //fprintf(stderr, "Load ext DTD was %i.\n", extd);
  
  xmlDocPtr entrydoc = xmlParseMemory(txt, strlen(txt));
  g_free(txt); 
  //fprintf(stderr, "entrydoc=%x\n", entrydoc);

  if(!entrydoc)
  {
    mystatus(_("Edited XML is not well formed! Can't save it!"));
    return FALSE;
  }

  // validate
  xmlDoValidityCheckingDefaultValue = 1;    
  xmlValidCtxtPtr ctx = xmlNewValidCtxt();
  xmlNodePtr entryRoot = xmlDocGetRootElement(entrydoc);
  gboolean valid = xmlValidateElement(ctx, teidoc, entryRoot);
  xmlFreeValidCtxt(ctx);
  //fprintf(stderr, "valid=%i\n", valid);
    
  if(!valid)
  {
    mystatus(_("Edited XML is not valid! Won't save it!"));
    return FALSE;
  }

  replace_edited_entry(entryRoot);
  gtk_text_buffer_set_modified(b, FALSE);
  return TRUE;
}


void
on_save_button_clicked                 (GtkButton       *button,
                                        gpointer         user_data)
{
  on_save1_activate(NULL, NULL);
}


void
on_new_entry_button_clicked            (GtkButton       *button,
                                        gpointer         user_data)
{
  g_return_if_fail(teidoc);

  xmlNodePtr bodyNode = find_single_node("/TEI.2/text/body[1]", teidoc);
  g_return_if_fail(bodyNode);
    
  // create new node and insert it into teidoc
  xmlNodePtr new_entry;
  
  // way 1: entry_template_doc
  if(entry_template_doc)
  {
    new_entry = xmlDocCopyNode(
	xmlDocGetRootElement(entry_template_doc), teidoc, 1);
    xmlNodePtr ret = xmlAddChild(bodyNode, new_entry);
    if(!ret)
    {
      mystatus(_("xmlAddChild(bodyNode, newEntry) failed!"));
      return;
    }
  }
  else // way 2: empty entry node (invalidates teidoc!)
    new_entry = xmlNewChild(bodyNode, NULL, "entry", "\n");	   

  // show in edit area
  set_edited_entry(new_entry);

  if(gtk_notebook_get_current_page(
	GTK_NOTEBOOK(lookup_widget(app1, "notebook1"))) == 1)
  {
    // copy text from "select" input field into orth field of new entry
    GtkWidget *entry1 = lookup_widget(app1, "entry1");
    const gchar* select1 = gtk_entry_get_text(GTK_ENTRY(
	  lookup_widget(app1, "select_entry")));
    gtk_entry_set_text(GTK_ENTRY(entry1), select1);

    gtk_widget_grab_focus(entry1);
  }

#define MAX_NEW_ENTRY_TIMESTAMPS 15 
  static long long int new_entry_timestamps[MAX_NEW_ENTRY_TIMESTAMPS];
  static int current_new_entry_timestamp_index;

  struct timeval tv;
  double speed = 0;
  if(gettimeofday(&tv, NULL) == 0)
  {
    // save timestamps in milliseconds
    new_entry_timestamps[current_new_entry_timestamp_index] =
      tv.tv_sec*1e3 + tv.tv_usec/1e3;
    //g_printerr("msec=%lli\n",
    //   	new_entry_timestamps[current_new_entry_timestamp_index]);
    current_new_entry_timestamp_index++;
    if(current_new_entry_timestamp_index>=MAX_NEW_ENTRY_TIMESTAMPS)
      current_new_entry_timestamp_index = 0;
    int i, valid = 0;
    long long int lowest = new_entry_timestamps[0];
    for(i=0; i<MAX_NEW_ENTRY_TIMESTAMPS; i++)
    {
      long long int cur = new_entry_timestamps[i];
      if(cur)
      {
	valid++;
	speed += cur;
	if(cur < lowest) lowest = cur;
      }
    }
    //g_printerr("sum of timestamps=%f valid=%i lowest=%lli\n",
    //   	speed, valid, lowest);
    if(valid>1) speed = 60*60*1000.0 / (speed/(gdouble)valid - lowest);
    else speed = 0;
  }

  mystatus(_("New entry created and editable. Speed: %2.1f entries/hour"), speed);
}


// deletes currently edited entry
void
on_delete_button_clicked               (GtkButton       *button,
                                        gpointer         user_data)
{
  g_return_if_fail(edited_entry);
  xmlUnlinkNode(edited_entry);
  xmlFree(edited_entry);
  set_edited_entry(NULL);
  // update treeview1
  on_select_entry_changed(NULL, NULL);
}


// returns whether saving was successful
gboolean save_form()
{
  g_return_val_if_fail(form_modified, TRUE);
  xmlNodePtr modified_entry = form2xml(senses);

  //g_printerr("Dump of modified_entry:\n");
  //dump_node(modified_entry);
  
  // validate
  xmlDoValidityCheckingDefaultValue = 1;    
  
  xmlValidCtxtPtr ctx = xmlNewValidCtxt();
  gboolean valid = xmlValidateElement(ctx, teidoc, modified_entry);
  xmlFreeValidCtxt(ctx);
    
  if(!valid)
  {
    mystatus(_("Edited XML is not valid! Won't save it!"));
    return FALSE;
  }

  replace_edited_entry(modified_entry);
  return TRUE;
}


void on_form_modified_changed()
{
  gtk_widget_set_sensitive(lookup_widget(app1, "apply_button"),
      teidoc && form_modified);
  gtk_widget_set_sensitive(lookup_widget(app1, "cancel_edit_button"),
      teidoc && form_modified);
}


void
on_notebook1_switch_page               (GtkNotebook     *notebook,
                                        GtkNotebookPage *page,
                                        guint            page_num,
                                        gpointer         user_data)
{
  //g_printerr(G_STRLOC ": on_notebook1_switch_page to pagenum=%i\n", page_num);

  // we can do this check usefully only since edited_entry is temporarily set
  // to NULL in set_edited_entry()
  if(!edited_entry) return;

  // the user switched the view
  
  // XXX the following code shouldnt be in a notification function, since
  // it may have to prevent swiching

  if(page_num==1)
  {
    // XXX unconditional auto-save is bad here, we should better prevent
    // switching if saving fails 
    
    // save contents of textview1
    save_textview1();
    
    // fill form
    if(!xml2form(edited_entry, senses))
      mystatus(_("Cannot handle entry with form :("));
      // XXX prevent switching to Form View even here
    else
    {
      if(form_modified) { form_modified = FALSE; on_form_modified_changed(); }
    }
  }
  else if(page_num==0)
  {
    // save contents of form
    if(edited_entry && !save_form())
      g_printerr(_("Saving form contents as XML failed :("));

    // fill textview1
    show_in_textview1(edited_entry);
  }
}


void
on_add_sense_button_clicked            (GtkButton       *button,
                                        gpointer         user_data)
{
  Sense *s = senses_append(senses);
  sense_append_trans(s); 
  on_form_entry_changed(NULL, NULL);
}


void
on_remove_sense_button_clicked         (GtkButton       *button,
                                        gpointer         user_data)
{
  senses_remove_last(senses); 
  on_form_entry_changed(NULL, NULL);
}


void on_textview1_modified_changed(GtkTextBuffer *textbuffer,
   gpointer user_data)
{
  g_return_if_fail(textbuffer);
  gboolean sensitive = teidoc && gtk_text_buffer_get_modified(textbuffer);
  gtk_widget_set_sensitive(lookup_widget(app1, "apply_button"),
      sensitive);
  gtk_widget_set_sensitive(lookup_widget(app1, "cancel_edit_button"),
      sensitive);
}


void on_lock_dockitems_toggled(GtkCheckMenuItem *item, gpointer user_data)
{
  gboolean locked = gtk_check_menu_item_get_active(item);
 
  // the docking classes are not documented in the libbonoboui docs
  // because the api is considered as unstable
  BonoboDock *bonobodock1 = BONOBO_DOCK(lookup_widget(app1, "bonobodock1")); 

  void on_lock_dockitems_list_callback2(gpointer data, gpointer user_data)
  {
    BonoboDockBandChild *child = (BonoboDockBandChild*) data;

    // see also /opt/gnome/include/libbonoboui-2.0/bonobo/bonobo-dock-item.h
    BonoboDockItem *item = 0;
    item = BONOBO_DOCK_ITEM(child->widget);
    g_return_if_fail(item); 

    //g_printerr("Name of this bonobo dock item: '%s'\n", item->name);

    // bonobo_dock_item_set_locked() is private, actually
    // /opt/gnome/include/libbonoboui-2.0/bonobo/bonobo-dock.h
    bonobo_dock_item_set_locked(item, locked);
  }

  void on_lock_dockitems_list_callback(gpointer data, gpointer user_data)
  {
    BonoboDockBand *item = (BonoboDockBand*) data;

    g_list_foreach(item->children, on_lock_dockitems_list_callback2, NULL);
    // don't do it for item->floating_child
  }
    
  // traverse GList *top_bands, *bottom_bands, *right_bands, *left_bands,
  // but maybe not GList *floating_children, so you can still move them
  g_list_foreach(bonobodock1->top_bands, on_lock_dockitems_list_callback, NULL);
  g_list_foreach(bonobodock1->bottom_bands, on_lock_dockitems_list_callback, NULL);
  g_list_foreach(bonobodock1->right_bands, on_lock_dockitems_list_callback, NULL);
  g_list_foreach(bonobodock1->left_bands, on_lock_dockitems_list_callback, NULL);
}


void my_widget_set_visible(GtkWidget *w, gboolean visible)
{
  if(visible) gtk_widget_show(w);
  else gtk_widget_hide(w);
}


void on_view_html_toggled(GtkCheckMenuItem *item, gpointer user_data)
{
  my_widget_set_visible(GTK_WIDGET(html_view),
      gtk_check_menu_item_get_active(item));
}


void on_view_toolbar_toggled(GtkCheckMenuItem *item, gpointer user_data)
{
  BonoboDockItem *i = bonobo_dock_get_item_by_name(
      BONOBO_DOCK(lookup_widget(app1, "bonobodock1")),
      "toolbar1", NULL, NULL, NULL, NULL);
  my_widget_set_visible(GTK_WIDGET(i), gtk_check_menu_item_get_active(item));
}


// remember state, so new entry editor widgets can be set visible or not
// XXX save state with gconf
gboolean labels_visible;

void on_view_labels_toggled(GtkCheckMenuItem *item, gpointer user_data)
{
  labels_visible = gtk_check_menu_item_get_active(item);
  my_widget_set_visible(lookup_widget(app1, "select_label"), labels_visible);
  my_widget_set_visible(lookup_widget(app1, "xpath_template_label"), labels_visible);
  my_widget_set_visible(lookup_widget(app1, "orth_label"), labels_visible);
  my_widget_set_visible(lookup_widget(app1, "pron_label"), labels_visible);
  my_widget_set_visible(lookup_widget(app1, "pos_label"), labels_visible);
  my_widget_set_visible(lookup_widget(app1, "num_label"), labels_visible);
  my_widget_set_visible(lookup_widget(app1, "gen_label"), labels_visible);

  // for all senses
  int i;
  for(i = 0; i < senses->len; i++)
  {
    Sense s = g_array_index(senses, Sense, i);
    my_widget_set_visible(s.domain_label, labels_visible);
    my_widget_set_visible(s.tr_label, labels_visible);
    my_widget_set_visible(s.tr_add_label, labels_visible);
    my_widget_set_visible(s.tr_delete_label, labels_visible);
    my_widget_set_visible(s.def_label, labels_visible);
    my_widget_set_visible(s.note_label, labels_visible);
    my_widget_set_visible(s.example_label, labels_visible);
    my_widget_set_visible(s.xr_label, labels_visible);
    my_widget_set_visible(s.xr_add_label, labels_visible);
    my_widget_set_visible(s.xr_delete_label, labels_visible);
  }
}


// try to show corresponding entry
// since there might be several matches, set select_entry
// and display preview of the first match
static void on_link_clicked(HtmlDocument *doc, const gchar *url, gpointer data)
{
  g_printerr("on_link_clicked: url='%s'\n", url);
  g_return_if_fail(url);
 
  // XXX decode url

  // XXX better: find exact matches only
  gtk_entry_set_text(GTK_ENTRY(
	  lookup_widget(app1, "select_entry")), url);

  // XXX exhibits a SEGFAULT 
  gtk_tree_view_set_cursor(GTK_TREE_VIEW(lookup_widget(app1, "treeview1")),
      gtk_tree_path_new_from_string("0"), NULL, FALSE);
}

// forward declaration
static void on_gconf_client_notify(GConfClient *client, guint cnxn_id,
    GConfEntry *entry, gpointer user_data);

void
on_app1_show                           (GtkWidget       *widget,
                                        gpointer         user_data)
{

  //gconf_init(argc, argv, NULL);// XXX not reqd?
  gc_client = gconf_client_get_default();

  char* freedictkeypath = gnome_gconf_get_app_settings_relative(NULL, NULL);
  gconf_client_add_dir(gc_client, freedictkeypath,
                       GCONF_CLIENT_PRELOAD_RECURSIVE,
                       NULL);
  gconf_client_notify_add(gc_client, freedictkeypath,
                          on_gconf_client_notify,
                          NULL,
                          NULL, NULL);
  g_free(freedictkeypath);

  // XXX load settings
  if(!stylesheetfn)
  {
    char* stylesheetkey = gnome_gconf_get_app_settings_relative(NULL, "stylesheet");
    stylesheetfn = gconf_client_get_string(gc_client, stylesheetkey, NULL);
    g_free(stylesheetkey);

    // key was empty: use default
    if(!stylesheetfn)
    {

      // fetch FREEDICTDIR environment variable
      const char *fdd = getenv("FREEDICTDIR");
      if(!fdd) fdd = "/usr/local/src/freedict";
      
      stylesheetfn = g_strdup_printf("%s/tools/xsl/tei2htm.xsl", fdd);
      
      g_printerr("Key was empty. Using default: %s\n", stylesheetfn);
    }
    else g_printerr("Using stylesheet filename from gconf: %s\n", stylesheetfn);
  }

  if(!entry_template_doc)
  {
    xmlDoValidityCheckingDefaultValue = 0;
    const char fname[] = PACKAGE_DATA_DIR "/" PACKAGE "/entry-template.xml";
    entry_template_doc = xmlParseFile(fname);
    if(!entry_template_doc)
      mystatus(_("Could not load %s!"), fname);
  }
 
  if(!entry_stylesheet)
  {
    entry_stylesheet =
      xsltParseStylesheetFile(stylesheetfn);
    if(!entry_stylesheet)
    {
      mystatus(_("Could not load entry stylesheet %s. HTML Preview won't work!"),
	  stylesheetfn);
    }
    else
    {
      html_view = html_view_new();
      gtk_paned_pack2 (GTK_PANED (lookup_widget(app1, "vpaned1")),
	  html_view, FALSE, TRUE);
      htdoc = html_document_new();
      g_signal_connect((gpointer) htdoc, "link_clicked",                          
	  G_CALLBACK(on_link_clicked), NULL);
      html_view_set_document(HTML_VIEW(html_view), htdoc);
      gtk_widget_show(html_view);
    }
  }

  if(!senses) senses = g_array_new(FALSE, TRUE, sizeof(Sense)); 

  GtkTextView *textview1 = GTK_TEXT_VIEW(lookup_widget(app1, "textview1"));
  GtkTextBuffer* b = gtk_text_view_get_buffer(textview1);

  // XXX ugly
  GtkTextTag *tag = gtk_text_buffer_create_tag(b, "instructions",
      "foreground", "blue", 
      "scale", PANGO_SCALE_X_LARGE,
      "wrap-mode", GTK_WRAP_WORD,
      NULL);

  // we could connect to this signal in glade-2 by entering the signal name
  // manually, but glade-2 should offer it in its "Select Signal" dialog
  // XXX fix glade-2
  g_signal_connect((gpointer) b, "modified-changed",
      G_CALLBACK(on_textview1_modified_changed), NULL);

  // the following signal handlers are not connected by glade-2,
  // even though the signal handler can be set in the property editor
  g_signal_connect ((gpointer) lookup_widget(app1, "view_html"), "toggled",
      G_CALLBACK (on_view_html_toggled), NULL);	
  g_signal_connect ((gpointer) lookup_widget(app1, "lock_dockitems"), "toggled",
      G_CALLBACK (on_lock_dockitems_toggled), NULL);	
  g_signal_connect ((gpointer) lookup_widget(app1, "view_labels"), "toggled",
      G_CALLBACK (on_view_labels_toggled), NULL);	
  g_signal_connect ((gpointer) lookup_widget(app1, "view_toolbar"), "toggled",
      G_CALLBACK (on_view_toolbar_toggled), NULL);	
  
  setTeidoc(NULL);

  // XXX using literal "FreeDict-Editor" is not nice
  // XXX the accel paths don't work :(
  create_menu(
      GTK_OPTION_MENU(lookup_widget(app1, "pos_optionmenu")),
      "<FreeDict-Editor>/Headword/pos",
      pos_values);

  gtk_menu_set_accel_path(
      GTK_MENU(gtk_option_menu_get_menu(
	  GTK_OPTION_MENU(lookup_widget(app1, "num_optionmenu")))),
      "<FreeDict-Editor>/Headword/num");

  // enable drops
  static GtkTargetEntry target_table[] = {
    // I found this target type searching through the GTK sources, as in the
    // docs a table giving frequently used target types is missing.
    // An URI-List is a list of URIs like "file:///path/filename",
    // where each URI is terminated with a "\r\n".
    // XXX extend gtk documentation
    { "text/uri-list", 0, 0 }
    //    { "text/plain", 0, 0 }
  };
  gtk_drag_dest_set(app1, GTK_DEST_DEFAULT_ALL, target_table, 1,
     GDK_ACTION_COPY
     );
}


void show_html_preview(xmlNodePtr entry)
{
  g_return_if_fail(entry);
  g_return_if_fail(entry_stylesheet);
  
  // assert HTML preview is enabled
  // do not check it (again)
  
  xmlDocPtr xml_entry = copy_node_to_doc(entry);
  const char *params[1] = { NULL };
  xmlDocPtr html_entry = xsltApplyStylesheet(entry_stylesheet,
      xml_entry, params);
  if(xml_entry) xmlFreeDoc(xml_entry);

  if(!html_entry)
  {
    mystatus(_("Error converting entry to HTML!"));
    return;
  }

  xmlChar *txt;
  int len;
  int bytes = xsltSaveResultToString(&txt, &len, html_entry,
      entry_stylesheet);
    
  html_document_open_stream(htdoc, "text/html");
  char enc[] = "<meta http-equiv=\"Content-Type\" "
    "content=\"text/html; charset=utf-8\">";
  html_document_write_stream(htdoc, enc, sizeof(enc));

  char err[] = N_("Error converting entry to HTML!");
  if(bytes == -1 || !txt)
    html_document_write_stream(htdoc, _(err), sizeof(_(err)));
  else html_document_write_stream(htdoc, txt, len);
  html_document_close_stream(htdoc);
  //xsltSaveResultToFile(stdout, html_entry, entry_stylesheet);
  xmlFreeDoc(html_entry);
}


void
on_apply_button_clicked                (GtkButton       *button,
                                        gpointer         user_data)
{
  switch(gtk_notebook_get_current_page(GTK_NOTEBOOK(
	  lookup_widget(app1, "notebook1"))))
  {
    case 0:
      save_textview1();
      break;
      
    case 1:
      // save contents of form
      if(!save_form()) g_printerr(_("Saving form contents as XML failed."));
      else gtk_widget_grab_focus(lookup_widget(app1, "select_entry"));
      break;

    default:
      g_assert_not_reached();
  }

  show_html_preview(edited_entry);
}


void
on_form_entry_changed                  (GtkEditable     *editable,
                                        gpointer         user_data)
{
  if(form_modified) return;
  form_modified = TRUE;
  on_form_modified_changed();
}


void
on_form_optionmenu_changed             (GtkOptionMenu   *optionmenu,
                                        gpointer         user_data)
{
  if(form_modified) return;
  form_modified = TRUE;
  on_form_modified_changed();
}



void
on_cancel_edit_button_clicked          (GtkButton       *button,
                                        gpointer         user_data)
{
  set_edited_entry(edited_entry);
}


void
on_treeview1_cursor_changed            (GtkTreeView     *treeview,
                                        gpointer         user_data)
{
  // return if HTML preview off
  if(!gtk_check_menu_item_get_active(GTK_CHECK_MENU_ITEM(
	  lookup_widget(app1, "view_html")))) return;
      
  // get currently selected entry
  GtkTreeView *tv = GTK_TREE_VIEW(lookup_widget(app1, "treeview1"));
  g_return_if_fail(tv);
  GtkTreePath *path;
  GtkTreeViewColumn *dummycol; 
  gtk_tree_view_get_cursor(tv, &path, &dummycol);
  g_return_if_fail(path);
  GtkTreeIter iter;
  gboolean ret = gtk_tree_model_get_iter(GTK_TREE_MODEL(store), &iter, path);
  g_assert(ret);
  xmlNodePtr e;
  gtk_tree_model_get(GTK_TREE_MODEL(store), &iter, 1, &e, -1);
 
  g_return_if_fail(e);
  // show it in HTML preview area
  show_html_preview(e);
}


#undef BONOBO_EXPERIMENT
//#define BONOBO_EXPERIMENT 0
#include <libbonoboui.h>
#include "Spell-1.0.5.h"
#ifdef BONOBO_EXPERIMENT
void
on_bonobo_experiment1_activate         (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  //const gchar *interfaces[] = { "IDL:Bonobo/Control:1.0", NULL };
  const gchar *interfaces[] = { "IDL:GNOME/Spell/Dictionary:0.3", NULL };

  CORBA_Environment ev;
  CORBA_exception_init (&ev);
  Bonobo_ServerInfoList* list = bonobo_activation_query
    ("repo_ids.has ('IDL:GNOME/Spell/Dictionary:0.3')", NULL, &ev);
  if(BONOBO_EX(&ev))
    g_print("bonobo_activation_query exception text: %s\n", bonobo_exception_get_text(&ev));
      
  g_print("activating spellchecker\n");
  // see /opt/gnome/lib/bonobo/servers/GNOME_Spell.server
  // and /opt/gnome/share/idl/Spell-1.0.5.idl
  CORBA_exception_init(&ev);
  GNOME_Spell_Dictionary o =
    bonobo_activation_activate_from_id ("OAFIID:GNOME_Spell_Dictionary:0.3", 0, NULL, &ev);      
//    bonobo_activation_activate
//    ("repo_ids.has ('IDL:GNOME/Spell/Dictionary:0.3')", NULL, 0, NULL, &ev);
  if(BONOBO_EX(&ev))
    g_print("bonobo_activation_activate exception text: %s\n", bonobo_exception_get_text(&ev));

  CORBA_exception_init (&ev);
  GNOME_Spell_LanguageSeq *langs = GNOME_Spell_Dictionary_getLanguages(o, &ev);
  if(BONOBO_EX(&ev))
    g_print("GNOME_Spell_Dictionary_getLanguages exception text: %s\n", bonobo_exception_get_text(&ev));
  else
  {
    //printf("_maximum=%lu _length=%lu _release=%i\n", langs->_maximum, langs->_length, langs->_release);
    int i = 0;
    while(i < langs->_length)
    {
      GNOME_Spell_Language *lang = langs->_buffer + i;
      //printf("  lang=%x\n", lang);
      if(lang)
	printf("lang[%i]: name=%s, abbrev=%s\n", i, lang->name, lang->abbreviation);
      i++;
    }
  }
  /* bonobo_selector_select_id() creates the following error:
     GLib-ERROR **: gmem.c:174: failed to allocate 2691719680 bytes
     aborting... */
  /*
     g_warning("opening selector\n");
     char *oaf_iid = bonobo_selector_select_id( _("Please select a Control"), interfaces);
     g_warning ("You selected '%s'\n", oaf_iid);
     g_free (oaf_iid);
   */
#else
void on_bonobo_experiment1_activate(GtkMenuItem *i, gpointer user_data)
{
  g_printerr("BONOBO_EXPERIMENT was disabled at compile time.\n");
#endif // BONOBO_EXPERIMENT
}


void
on_app1_drag_data_received             (GtkWidget       *widget,
                                        GdkDragContext  *drag_context,
                                        gint             x,
                                        gint             y,
                                        GtkSelectionData *data,
                                        guint            info,
                                        guint            time,
                                        gpointer         user_data)
{
  // don't accept drops if we have unsaved changes
  if(file_modified)
  {
    mystatus(_("No Drops accepted while unsaved changes in memory."));
    return;
  }
    
  //g_print("Got: %s\n",data->data);

  if(!strncmp(data->data, "file://", 7))
  {
    static char myfilename[200];
    char *end = strstr(data->data + 7, "\r\n");
    if(end)
    {
      *end = 0;
      strncpy(myfilename, data->data + 7, sizeof(myfilename));
      //g_print("Trying to load '%s'\n", myfilename);
      selected_filename = myfilename;

      myload(selected_filename);
    }
    else
      mystatus(_("Did not recognize URI in Drop (no \\r\\n): %s\n"), data->data);
  }
  else
    mystatus(_("Did not recognize file-URI in Drop: %s\n"), data->data);
}


char *saved_global_im_context_id = NULL;


gboolean
on_entry2_focus_in_event               (GtkWidget       *widget,
                                        GdkEventFocus   *event,
                                        gpointer         user_data)
{
  // remember global IM
  saved_global_im_context_id = find_global_im_gtk_context_id();
  //printf("Global GTK+ IM Context ID: %s\n", saved_global_im_context_id);
  
  // set IPA input method
  set_global_im_gtk_context_id("ipa");
  return FALSE;
}


gboolean
on_entry2_focus_out_event              (GtkWidget       *widget,
                                        GdkEventFocus   *event,
                                        gpointer         user_data)
{
  //printf("Switching global GTK+ IM back to: %s\n", saved_global_im_context_id);
  set_global_im_gtk_context_id(saved_global_im_context_id);
  return FALSE;
}


void
on_edit_header_activate                (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  g_printerr("on_edit_header_activate\n");
  g_return_if_fail(teidoc);
  
  // find header node
  xmlNodePtr h = find_single_node("/TEI.2/teiHeader", teidoc);
  g_return_if_fail(h);
  
  show_in_textview1(h);
  gtk_notebook_set_current_page(GTK_NOTEBOOK(lookup_widget(app1, "notebook1")), 0);
  
  // disable switching to Form View
  gtk_widget_set_sensitive(lookup_widget(app1, "form_view_label"), FALSE);
  // XXX has to be enabled again!
}

void
on_view_keyboard_layout_activate       (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  // XXX get group and shift level from dialog
  
  gchar *xkbprintpath = g_find_program_in_path("xkbprint");
  gchar *gvpath = g_find_program_in_path("gv");

  const char commandline[] =
    "xkbprint -color -lg 1 -ll 1 :0 - | gv -seascape -";
  if(gnome_execute_terminal_shell(NULL, commandline) != -1) return;
  mystatus("Failed to show keyboard layout.");
}

///////////////////////////////////////////////////////////////////////////
// spelling code
///////////////////////////////////////////////////////////////////////////

// /usr/include/aspell.h
#include <aspell.h>
AspellConfig *c;
AspellSpeller *s;
AspellCanHaveError *possible_err; 

GtkWidget *scw;
GtkListStore *spell_sugg_store;
GtkCellRenderer *spell_sugg_renderer;
GtkTreeViewColumn *spell_sugg_column;

xmlNodeSetPtr spell_nodes;
int spell_current_node_idx;
xmlNodePtr spell_current_node;
gchar** spell_current_words;
int spell_current_word_idx;

// XXX this callback is too lowlevel as it gets called too often
// that is bad because maybe new_aspell_speller() is expensive
void on_spell_dict_combo_list_select_child(GtkList *list, GtkWidget *litem,
    gpointer user_data)
{
  g_print("on_spell_dict_combo_list_select_child()\n");
  g_return_if_fail(litem);
  g_return_if_fail(c);

  char *code = g_object_get_data(G_OBJECT(litem), "aspell-code");
  char *jargon = g_object_get_data(G_OBJECT(litem), "aspell-jargon");
  char *size = g_object_get_data(G_OBJECT(litem), "aspell-size");
  // is this correct??
  if(code) aspell_config_replace(c, "lang", code);
  if(jargon) aspell_config_replace(c, "jargon", jargon);
  if(size) aspell_config_replace(c, "size", size);
  
  if(s) { delete_aspell_speller(s); s=0; }

  possible_err = new_aspell_speller(c); 
  if(aspell_error_number(possible_err) != 0) 
    puts(aspell_error_message(possible_err)); 
  else s = to_aspell_speller(possible_err); 

  g_return_if_fail(s);
}


void spell_getsuggestions(char *word)
{
  GtkTreeView *sugg_treeview = GTK_TREE_VIEW(
                lookup_widget(scw, "suggestions_treeview"));
  
  if(!spell_sugg_store)
  {
    spell_sugg_store = gtk_list_store_new(1, G_TYPE_STRING);
    gtk_tree_view_set_model(sugg_treeview,
	GTK_TREE_MODEL(spell_sugg_store));
  }
  else gtk_list_store_clear(spell_sugg_store);

  GtkTreeIter i;

  const AspellWordList *suggestions = aspell_speller_suggest(s, word, -1); 
  AspellStringEnumeration *elements = aspell_word_list_elements(suggestions); 
  const char *sugg; 
  while(sugg = aspell_string_enumeration_next(elements))
  { 
    // add to suggestion list
    gtk_list_store_append(spell_sugg_store, &i);// init i
    gtk_list_store_set(spell_sugg_store, &i, 0, sugg, -1);
  } 

  if(!spell_sugg_renderer)
  {
    spell_sugg_renderer = gtk_cell_renderer_text_new();
    spell_sugg_column = gtk_tree_view_column_new_with_attributes
      ("Sugestions", spell_sugg_renderer, "text", 0, NULL);
    gtk_tree_view_append_column(sugg_treeview, spell_sugg_column);
  }	
  delete_aspell_string_enumeration(elements); 

  // select first replacement
  gtk_tree_view_set_cursor(sugg_treeview, gtk_tree_path_new_from_string("0"), NULL, FALSE);
  // what about freeing the path?
  
  //will be called in effect:
  //on_suggestions_treeview_cursor_changed(GTK_TREE_VIEW(
  //	lookup_widget(scw, "suggestions_treeview")), NULL);
}


// This should be called for each word of the current node.  It returns TRUE,
// if a user decision is awaited and FALSE when a correct word was
// encountered.  It expects a next word to be available and returns FALSE if
// there isn't. But that condition should be checked by the caller.
gboolean spell_handle_current_word()
{
  g_return_val_if_fail(spell_current_words &&
      spell_current_words[spell_current_word_idx], FALSE);

  char *w = spell_current_words[spell_current_word_idx];
  g_print("Checking word %i: '%s'... ", spell_current_word_idx, w);

  int l = strlen(w);
  gboolean spell_saved_punct = FALSE;
  char spell_saved_char;
  if(l)
  {
    spell_saved_char = *(w + l -1);
    if(g_ascii_ispunct(spell_saved_char))
    {
      g_print("Word ends in punctuation character. Removing it temporarily. "
	  "How does aspell treat abbreviations?\n");
      *(w + l -1) = 0;
      spell_saved_punct = TRUE;
    }
  }

  int correct = aspell_speller_check(s, w, -1);
  g_print(" correct=%i\n", correct);

  if(spell_saved_punct)
    *(w + l -1) = spell_saved_char;

  if(correct) return FALSE;
  
  // XXX check replace_all map
  /* Looks up an element.
   * Returns null if the element did not exist.
   * Returns an empty string if the element exists but has a null value.
   * Otherwises returns the value 
   
   const char *aspell_string_map_lookup(const struct AspellStringMap *ths, const char *key);
  */

  gtk_entry_set_text(GTK_ENTRY(lookup_widget(scw, "misspelled_word_entry")),
      spell_current_words[spell_current_word_idx]);
  spell_getsuggestions(spell_current_words[spell_current_word_idx]);

  // look for an entry ancestor
  xmlNodePtr n = spell_current_node;
  while(n && n->name && strcmp(n->name, "entry"))
   n = n->parent;
  if(n && n->type==XML_ELEMENT_NODE)
  {
    show_html_preview(n);
    // mark word in preview
  }
  
  // now wait for user decision (replace, ignore etc.)
  return TRUE;
}


// This should be called for each text node to be spellchecked.  It returns
// TRUE if a user decision is awaited and FALSE if there are no more words in
// the current node.  It returns FALSE as well, when there is no current node
// or it is not a text node, but these conditions are expected to be checked
// by the caller.
gboolean spell_handle_current_node(void)
{
  g_return_val_if_fail(spell_current_node, FALSE);// no current node
  g_return_val_if_fail(xmlNodeIsText(spell_current_node), FALSE);// no text node
  
  if(!spell_current_words)
  { 
    xmlChar *spell_current_content = xmlNodeGetContent(spell_current_node);
    // XXX utf-8 -> iso8859-x
    // file:/opt/gnome/share/gtk-doc/html/glib/glib-Character-Set-Conversion.html 
    //g_warning("spell_current_content='%s'", spell_current_content);
 
    spell_current_words = g_strsplit(spell_current_content, " ", 40);
    //g_warning("after split words[0]='%s'", spell_current_words[0]);
    spell_current_word_idx = 0;
  }

  g_return_val_if_fail(spell_current_words, FALSE);// split failed

  while(spell_current_words[spell_current_word_idx])
  {
    if(spell_handle_current_word()) return TRUE;// wait for user decision
    spell_current_word_idx++;// next word
  }
  
  g_strfreev(spell_current_words);
  spell_current_words = 0;
  return FALSE;
}


void spell_continue_check()
{
  g_return_if_fail(s);// speller reqd
  while(1)
  {
    spell_current_node =
      xmlXPathNodeSetItem(spell_nodes, spell_current_node_idx);
 
    if(!spell_current_node) break;// finished spellcheck
    
    if(!xmlNodeIsText(spell_current_node))
    {
      g_warning("Node %i is no text node. Skip.", spell_current_node_idx);
      spell_current_node_idx++;
      continue;
    }

    // update progressbar
    gtk_progress_bar_set_fraction(GTK_PROGRESS_BAR(
	  lookup_widget(scw, "spell_progressbar")),
	(gdouble)spell_current_node_idx /
	(gdouble) xmlXPathNodeSetGetLength(spell_nodes));

    if(spell_handle_current_node()) return;// user decision awaited
    spell_current_node_idx++;
  }

  g_warning("Finished Spellcheck. What now?");
  // inactivate all buttons except "close",
  // update status bar
}


void
on_spell_check1_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  scw = create_spellcheck_window();
  gtk_widget_show_all(scw);

  // populate spelling dict combobox
  GtkWidget *combo = lookup_widget(scw, "spell_dict_combo");
  g_signal_connect((gpointer) GTK_COMBO(combo)->list, "select-child",
      G_CALLBACK (on_spell_dict_combo_list_select_child), NULL);

  c = new_aspell_config();
  AspellDictInfoList* l = get_aspell_dict_info_list(c);
  AspellDictInfoEnumeration *e = aspell_dict_info_list_elements(l);
  while(!aspell_dict_info_enumeration_at_end(e))
  {
    const AspellDictInfo *d = aspell_dict_info_enumeration_next(e);
    char item[100];
    snprintf(item, sizeof(item), _("%s, size=%s"),
        d->name, d->size_str);

    // GtkListItem is deprecated :(
    GtkWidget *litem = gtk_list_item_new_with_label(item);
    gtk_widget_show(litem);
    // the string to display in the entry field when the item is selected
    gtk_combo_set_item_string(GTK_COMBO(combo), GTK_ITEM(litem), item);
    gtk_container_add(GTK_CONTAINER(GTK_COMBO(combo)->list), litem);

    // XXX preselect aspell chosen dict in combobox
    // if(!strcmp(d->code, ) && !strcmp(d->jargon, ...) && d->size == ...)
    //   ...

    // save details so we can use them for aspell_config_replace()
    gchar *code2 = g_strndup(d->code, 30);
    gchar *jargon2 = g_strndup(d->jargon, 30);
    gchar *size_str2 = g_strndup(d->size_str, 30);
    g_assert(code2 !=0 && jargon2 != 0 && size_str2 != 0);
    g_object_set_data(G_OBJECT(litem), "aspell-code", code2);
    g_object_set_data(G_OBJECT(litem), "aspell-jargon", jargon2);
    g_object_set_data(G_OBJECT(litem), "aspell-size", size_str2);
  }
  delete_aspell_dict_info_enumeration(e);

  // build XPath query
  gboolean orth = gtk_toggle_button_get_active(
      GTK_TOGGLE_BUTTON(lookup_widget(scw, "spell_orth_checkbutton")));
  gboolean tr = gtk_toggle_button_get_active(
      GTK_TOGGLE_BUTTON(lookup_widget(scw, "spell_tr_checkbutton")));
  gboolean eg = gtk_toggle_button_get_active(
      GTK_TOGGLE_BUTTON(lookup_widget(scw, "spell_eg_checkbutton")));
  gboolean eg_tr = gtk_toggle_button_get_active(
      GTK_TOGGLE_BUTTON(lookup_widget(scw, "spell_eg_tr_checkbutton")));
  
  char query[100] = "";
  if(orth)
    g_strlcat(query, "//orth/text()", sizeof(query));
  if(tr)
  {
    if(strlen(query)) g_strlcat(query, " | ", sizeof(query));
    g_strlcat(query, "//tr/text()", sizeof(query));
  }
  if(eg)
  {
    if(strlen(query)) g_strlcat(query, " | ", sizeof(query));
    g_strlcat(query, "//eg/q/text()", sizeof(query));
  }
  if(eg_tr)
  {
    if(strlen(query)) g_strlcat(query, " | ", sizeof(query));
    g_strlcat(query, "//eg/trans/tr/text()", sizeof(query));
  }
  g_print("query: '%s'\n", query);
  
  spell_nodes = find_node_set(query, teidoc);
  g_print("nodes: %i\n", xmlXPathNodeSetGetLength(spell_nodes));

  g_return_if_fail(xmlXPathNodeSetGetLength(spell_nodes));

  spell_current_node_idx = 0;
  spell_continue_check();
  
  // XXX struct AspellStringMap * new_aspell_string_map();
}


void
on_spell_replace_button_clicked        (GtkButton       *button,
                                        gpointer         user_data)
{
  g_return_if_fail(spell_current_words && spell_current_words[spell_current_word_idx]);
  
  GtkWidget *entry = lookup_widget(scw, "replacement_entry");
  char *replacement = g_strdup(gtk_entry_get_text(GTK_ENTRY(entry)));
  g_return_if_fail(replacement);

  char *old = spell_current_words[spell_current_word_idx];
  
  if(!strcmp(old, replacement))
  {
    g_print("There is no use in replacing a misspelled word with the same.\n");
    g_free(replacement);
    return;
  }
    
  g_print("Replacing %s with %s\n", old, replacement);
  // XXX replacing one word with two creates problem here
  // -> split again
  spell_current_words[spell_current_word_idx] = replacement;
  aspell_speller_store_replacement(s, old, -1, replacement, -1);
  g_free(old);

  gchar* new_content = g_strjoinv(" ", spell_current_words);
  g_print("New node content: '%s'\n", new_content);

  g_return_if_fail(spell_current_node);
  xmlChar *spell_current_content = xmlNodeGetContent(spell_current_node);
  g_print("Old node content: '%s'\n", spell_current_content);
  
  xmlNodeSetContent(spell_current_node, new_content);
  g_free(new_content);// ??

  if(!file_modified) { file_modified = TRUE; on_file_modified_changed(); }
  spell_continue_check();
}


void
on_spell_replace_all_button_clicked    (GtkButton       *button,
                                        gpointer         user_data)
{
  on_spell_replace_button_clicked(NULL, NULL);
  // XXX save in some map, maybe AspellStringMap
  //int aspell_string_map_add(struct AspellStringMap * ths, const char * to_add);
}


void
on_spell_ignore_button_clicked         (GtkButton       *button,
                                        gpointer         user_data)
{
  // handle next word
  spell_current_word_idx++;

  spell_continue_check();
}


void
on_spell_ignore_all_button_clicked     (GtkButton       *button,
                                        gpointer         user_data)
{
  g_return_if_fail(s);
  g_return_if_fail(spell_current_words);
  g_return_if_fail(spell_current_words[spell_current_word_idx]);

  int ret = aspell_speller_add_to_session(s, spell_current_words[spell_current_word_idx], -1);
  g_print("Storing '%s' in session word list gave %i (0 = error, 1 = success).\n",
      spell_current_words[spell_current_word_idx], ret);

  spell_continue_check();
}


void
on_spell_add_button_clicked            (GtkButton       *button,
                                        gpointer         user_data)
{
  g_return_if_fail(s);
  g_return_if_fail(spell_current_words);
  g_return_if_fail(spell_current_words[spell_current_word_idx]);

  int ret = aspell_speller_add_to_personal(s, spell_current_words[spell_current_word_idx], -1);
  g_print("Storing '%s' in personal word list gave %i (0 = error, 1 = success).\n",
      spell_current_words[spell_current_word_idx], ret);

  spell_continue_check();
}


void
on_spell_close_button_clicked          (GtkButton       *button,
                                        gpointer         user_data)
{
  if(spell_current_words)
  {
    g_strfreev(spell_current_words);
    spell_current_words = 0;
  }

  if(spell_nodes) { xmlXPathFreeNodeSet(spell_nodes); spell_nodes=0; }

  // XXX delete_aspell_string_map(struct AspellStringMap * ths);

  // optional: save session word list
  
  if(s) { delete_aspell_speller(s); s=0; }
  
  if(c) { delete_aspell_config(c); c=0; }
  
  // only delete this if cast to speller failed?
  //delete_aspell_can_have_error(possible_err);
  //g_warning("deleted possible_err");
  
  spell_sugg_store = 0;
  spell_sugg_renderer = 0;
  spell_sugg_column = 0;
  if(scw) { gtk_widget_destroy(scw); scw=0; }
  //g_warning("destroyed widget");
}


void
on_spell_headwords_radiobutton_toggled (GtkToggleButton *togglebutton,
                                        gpointer         user_data)
{
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	lookup_widget(scw, "spell_orth_checkbutton")), TRUE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	lookup_widget(scw, "spell_tr_checkbutton")), FALSE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	lookup_widget(scw, "spell_eg_checkbutton")), TRUE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	lookup_widget(scw, "spell_eg_tr_checkbutton")), FALSE);
}


void
on_spell_translations_radiobutton_toggled
                                        (GtkToggleButton *togglebutton,
                                        gpointer         user_data)
{
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	lookup_widget(scw, "spell_orth_checkbutton")), FALSE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	lookup_widget(scw, "spell_tr_checkbutton")), TRUE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	lookup_widget(scw, "spell_eg_checkbutton")), FALSE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	lookup_widget(scw, "spell_eg_tr_checkbutton")), TRUE);
}


// replace misspelled word with double-clicked suggestion
void
on_suggestions_treeview_row_activated  (GtkTreeView     *treeview,
                                        GtkTreePath     *path,
                                        GtkTreeViewColumn *column,
                                        gpointer         user_data)
{
  // since on_suggestions_treeview_cursor_changed() is always called before we
  // get called, we only need to click the replace button programmatically
  on_spell_replace_button_clicked(NULL, NULL);
}


void
on_suggestions_treeview_cursor_changed (GtkTreeView     *treeview,
                                        gpointer         user_data)
{
  // get currently selected entry
  g_return_if_fail(treeview);
  GtkTreePath *path;
  GtkTreeViewColumn *dummycol; 
  gtk_tree_view_get_cursor(treeview, &path, &dummycol);
  g_return_if_fail(path);
  GtkTreeIter iter;
  gboolean ret = gtk_tree_model_get_iter(GTK_TREE_MODEL(spell_sugg_store), &iter, path);
  g_assert(ret);
  char *sugg;
  gtk_tree_model_get(GTK_TREE_MODEL(spell_sugg_store), &iter, 0, &sugg, -1);
  g_return_if_fail(sugg);
  
  // put selected suggestion into replacement entry
  GtkWidget *entry = lookup_widget(scw, "replacement_entry");
  gtk_entry_set_text(GTK_ENTRY(entry), sugg);
}


void
on_new_file_button_clicked             (GtkButton       *button,
                                        gpointer         user_data)
{
  // activate corresponding menu entry
  on_new1_activate(NULL, NULL);
}


///////////////////////////////////////////////////////////////////////////
// property box code
//
// GnomePropertyBox is documented here:
// file:///opt/gnome/share/gtk-doc/html/libgnomeui/gnomepropertybox.html
//
// The config data is stored in a gconf database and we get notification
// when keys are changed using gconf-editor:
// file:///opt/gnome/share/gtk-doc/html/gconf/gconfclient.html  
//
// An alternative to using gconf would have been to store config data in a
// file in ~/.gnome2/:
// file:///opt/gnome/share/gtk-doc/html/libgnome/libgnome-gnome-config.html
///////////////////////////////////////////////////////////////////////////

void
on_gtkeditable_changed(GtkEditable *editable, gpointer user_data)
{
  g_return_if_fail(propertybox);
  // make the apply button sensitive
  gnome_property_box_changed(GNOME_PROPERTY_BOX(propertybox));
}


// see ~/dict/t/gnome-things/GConf-2.6.1/examples

void
on_preferences1_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  if(!propertybox)
  {
    propertybox = create_propertybox1();

    // XXX checkbox to use default or not

    // populate fields by taking the current variable values and
    // putting them into the input fields
    gnome_file_entry_set_filename(
	GNOME_FILE_ENTRY(lookup_widget(GTK_WIDGET(propertybox),
	    "stylesheet_fileentry")),
	stylesheetfn);
    // XXX make input field insensitive if key not writable
    
    gtk_label_set_text(GTK_LABEL(lookup_widget(GTK_WIDGET(propertybox),
	    "editer_default_name_label")), g_get_real_name());

    gtk_label_set_text(GTK_LABEL(lookup_widget(GTK_WIDGET(propertybox),
	    "editer_default_email_label")), g_get_user_name());
    // XXX ++ @localhost
  }
  
  gtk_widget_show_all(propertybox);
}


// Callback to be called by gconf. Was registered at application startup/
static void on_gconf_client_notify(GConfClient *client, guint cnxn_id,
    GConfEntry *entry, gpointer user_data)
{
  g_return_if_fail(entry);
  g_printerr("on_gconf_client_notify for key %s\n", entry->key);
  if(!gconf_entry_get_value(entry))
  {
    g_printerr("key was unset\n");
  }
  else
  {
    if(gconf_entry_get_value(entry)->type == GCONF_VALUE_STRING)
    {
      g_printerr("STRING: %s\n", 
	  gconf_value_get_string(gconf_entry_get_value(entry)));
    }
    else
    {
      g_printerr("Not STRING type\n");
    }
  }
}


void
on_propertybox1_apply                  (GnomePropertyBox *propertybox,
                                        gint             page_num,
                                        gpointer         user_data)
{
  g_return_if_fail(gc_client);
  g_printerr("on_propertybox1_apply\n");

  char* new_stylesheetfn = gnome_file_entry_get_full_path(
      GNOME_FILE_ENTRY(lookup_widget(GTK_WIDGET(propertybox), "stylesheet_fileentry")),
      TRUE); // file must exist
  char* stylesheetkey = gnome_gconf_get_app_settings_relative(NULL, "stylesheet");
  if(new_stylesheetfn)
    gconf_client_set_string(gc_client, stylesheetkey, new_stylesheetfn, NULL);
  else gconf_client_unset(gc_client, stylesheetkey, NULL);
  g_free(stylesheetkey);
  if(new_stylesheetfn) g_free(new_stylesheetfn);

  // XXX

  gconf_client_suggest_sync(gc_client, NULL);
}


void
on_propertybox1_help                   (GnomePropertyBox *propertybox,
                                        gint             page_num,
                                        gpointer         user_data)
{
  GError *error;
  if(gnome_help_display(PACKAGE ".xml", PACKAGE "-prefs",  &error)) return;
  
  // display error
  g_printerr(G_STRLOC ": gnome_help_display() failed. If you wnat to "
      "know more, ask the programmer to display error->message\n");
}


gboolean
on_propertybox1_close                  (GnomeDialog     *gnomedialog,
                                        gpointer         user_data)
{
  // no need to care for change status, since
  // GnomePropertyBox takes care of that

  gtk_widget_destroy(propertybox);
  propertybox = 0;
  return FALSE;
}


///////////////////////////////////////////////////////////////////////////
// sanity check code
///////////////////////////////////////////////////////////////////////////

enum
{
  CHECK_ENABLED_COLUMN,
  TITLE_COLUMN,
  HEADWORDS_COLUMN,
  ENTRY_POINTER_COLUMN,
  N_SANITY_COLUMNS
};

struct sanity_check
{
  const char *title;
  const char *select;// an XPath expression that returns a set of <entry> elements
};

static struct sanity_check sanity_checks[] = {
  { "Missing Part-of-Speech",
    "//entry[ not(gramGrp/pos) ]" },
  { "Nouns without Gender",
    "//entry[ gramGrp/pos='n' and not(gramGrp/gen) ]" },
  { "Notes with Question Marks",
    "//entry[ .//note[contains(., '?')] ]" },
  { "Empty Headwords",
    "//entry[ form/orth[ normalize-space()='' ] or count(form/orth)<1 ]" },
  { "Empty Body",
    "//entry[ *[ not(form) and normalize-space()='' ] ]" },
    
  // too slow
  { "Homographs of same Part-of-Speech",
    "//entry[ form/orth = preceding-sibling::entry/form/orth | "
      "following-sibling::entry/form/orth and "
      "gramGrp/pos = preceding-sibling::entry/gramGrp/pos | "
      "following-sibling::entry/gramGrp/pos ]" },
    
  { "Broken Cross-References",
    "//entry[ count(sense/xr/ref) != count( sense/xr/ref "
      "[../../../preceding-sibling::entry/form/orth | "
      "../../../following-sibling::entry/form/orth = .]) ]" },
  { "Multiple Headwords",
    "//entry[ count(form/orth) > 1 ]" },
  NULL };

GtkWidget* sanity_window;
GtkTreeStore *sanity_store;


void
on_sanity_check_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  if(!sanity_window) sanity_window = create_sanity_window();
  gtk_window_present(GTK_WINDOW(sanity_window));
}


void
on_sanity_treeview_row_activated       (GtkTreeView     *treeview,
                                        GtkTreePath     *path,
                                        GtkTreeViewColumn *column,
                                        gpointer         user_data)
{
  // open entry in entry editor
  GtkTreeIter iter;
  gboolean ret = gtk_tree_model_get_iter(GTK_TREE_MODEL(sanity_store), &iter, path);
  g_assert(ret);
  xmlNodePtr e;
  gtk_tree_model_get(GTK_TREE_MODEL(sanity_store), &iter, ENTRY_POINTER_COLUMN, &e, -1);

  // header columns have no associated entry
  if(!e) return;
  
  // XXX what if e has been deleted already?
  // the pointer is not NULL yet!
  // maybe on entry delete/modify update sanity window data!
  set_edited_entry(e);
}


void
on_sanity_treeview_cursor_changed      (GtkTreeView     *treeview,
                                        gpointer         user_data)
{
   // return if HTML preview off
  if(!gtk_check_menu_item_get_active(GTK_CHECK_MENU_ITEM(
	  lookup_widget(app1, "view_html")))) return;
      
  // get currently selected entry
  g_return_if_fail(treeview);
  GtkTreePath *path;
  GtkTreeViewColumn *dummycol; 
  gtk_tree_view_get_cursor(treeview, &path, &dummycol);
  g_return_if_fail(path);
  GtkTreeIter iter;
  gboolean ret = gtk_tree_model_get_iter(GTK_TREE_MODEL(sanity_store), &iter, path);
  g_assert(ret);
  xmlNodePtr e;
  gtk_tree_model_get(GTK_TREE_MODEL(sanity_store), &iter, ENTRY_POINTER_COLUMN, &e, -1);
  
  // header columns have no associated entry
  if(!e) return;
  
  // show entry in HTML preview area
  show_html_preview(e);
}


gboolean
on_sanity_treeview_expand_collapse_cursor_row
                                        (GtkTreeView     *treeview,
                                        gboolean         logical,
                                        gboolean         expand,
                                        gboolean         open_all,
                                        gpointer         user_data)
{
  g_printerr("on_sanity_treeview_expand_collapse_cursor_row\n");
  // XXX perform check on expand
  // XXX this function does not get called
  // maybe on_sanity_treeview_expand_collapse_cursor_row is more appropriate?
  return FALSE;
}


void
on_sanity_treeview_show                (GtkWidget       *widget,
                                        gpointer         user_data)
{
  g_printerr("on_sanity_treeview_show\n");
  // XXX obsolete?
}


void
on_sanity_window_show                  (GtkWidget       *widget,
                                        gpointer         user_data)
{
  g_printerr("on_sanity_window_show\n");

  // XXX save enablement status with gconf
  
  sanity_store = gtk_tree_store_new(
      N_SANITY_COLUMNS,
      G_TYPE_BOOLEAN,
      G_TYPE_STRING,   /* Name of Sanity Check */
      G_TYPE_STRING,   /* Headwords of marching entries */
      G_TYPE_POINTER   /* xmlNodePtr to the entry */
      );

  GtkTreeIter root_i, child_i;

  // all checks
  struct sanity_check *check = sanity_checks;
  while(check->title)
  {
    // XXX if check enabled

    // perform current check
    g_assert(check->select);
    g_assert(teidoc);
    g_printerr("Checking for '%s'\n\twith '%s'... ", check->title, check->select);
    xmlNodeSetPtr matches = find_node_set(check->select, teidoc);
    int nr = 0;
    if(matches) nr = matches->nodeNr;
    g_printerr("%i matches.\n", nr);

    // print number of matches in TITLE_COLUMN
		char title_string[99];
    g_snprintf(title_string, sizeof(title_string), "%s (%i matches)",
      check->title, nr);
    gtk_tree_store_append(sanity_store, &root_i, NULL);
    gtk_tree_store_set(sanity_store, &root_i,
	CHECK_ENABLED_COLUMN, TRUE, // XXX	
        TITLE_COLUMN, title_string,
       	-1);

    if(matches)
    {
      // for first 50 matching entries
      int j = 0;
      xmlNodePtr *n, *n2;
      for(j=0, n=matches->nodeTab; *n && j<matches->nodeNr && j<50; n++, j++)
      {
	char headwords[100];
	entry_orths_to_string(*n, sizeof(headwords), headwords);
	gtk_tree_store_append(sanity_store, &child_i, &root_i);
      	gtk_tree_store_set(sanity_store, &child_i,
	    HEADWORDS_COLUMN, headwords,
	    ENTRY_POINTER_COLUMN, *n,
	    -1);
      }
      
      // add "..."
      if(j==50)
      {
	gtk_tree_store_append(sanity_store, &child_i, &root_i);
      	gtk_tree_store_set(sanity_store, &child_i,
	    HEADWORDS_COLUMN, "...",
	    -1);
      }
    } // if(matches)
    check++;
  } // while(check->title)

  GtkTreeView *sanity_tree_view;
  sanity_tree_view = GTK_TREE_VIEW(lookup_widget(sanity_window, "sanity_treeview"));
  gtk_tree_view_set_model(sanity_tree_view, GTK_TREE_MODEL(sanity_store));

  GtkCellRenderer *renderer;
  GtkTreeViewColumn *column;

  renderer = gtk_cell_renderer_toggle_new();
  column = gtk_tree_view_column_new_with_attributes(
      "Check Enabled?", renderer, "active", CHECK_ENABLED_COLUMN, NULL);
  gtk_tree_view_append_column(sanity_tree_view, column);
  
  renderer = gtk_cell_renderer_text_new();
  column = gtk_tree_view_column_new_with_attributes(
      "Check", renderer, "text", TITLE_COLUMN, NULL);
  gtk_tree_view_append_column(sanity_tree_view, column);

  renderer = gtk_cell_renderer_text_new();
  column = gtk_tree_view_column_new_with_attributes(
      "Matching Entries", renderer, "text", HEADWORDS_COLUMN, NULL);
  gtk_tree_view_append_column(sanity_tree_view, column);
}


void
on_sanity_treeview_row_expanded        (GtkTreeView     *treeview,
                                        GtkTreeIter     *iter,
                                        GtkTreePath     *path,
                                        gpointer         user_data)
{
  g_printerr("on_sanity_treeview_expand_collapse_cursor_row\n");

}


///////////////////////////////////////////////////////////////////////////
// maybe uncategorized code follows
///////////////////////////////////////////////////////////////////////////

