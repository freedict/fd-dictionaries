/** @file
 * @brief GUI Callback functions. New functions are appended by Glade here
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gnome.h>
#include <glade/glade.h>
#include <libgtkhtml/gtkhtml.h>
#include <gconf/gconf-client.h>

#if !defined(LIBXML_THREAD_ENABLED)
#pragma error "libxml2 needs to have threads enabled!"
#endif
#include <libxml/threads.h>
#include <libxml/uri.h>

#include <bonobo/bonobo-dock-item.h>

#include "callbacks.h"
#include "utils.h"
#include "xml.h"
#include "entryedit.h"

/// GladeXML object of the application to access widgets
extern GladeXML *my_glade_xml;

/// Currently open dictionary
xmlDocPtr teidoc;

/// Template used for new entries
xmlDocPtr entry_template_doc;

/// Node currently open for editing in the entry editor
xmlNodePtr edited_node;

/// Stylesheet to transform TEI to HTML
xsltStylesheetPtr entry_stylesheet;

/// HTML Document for entry preview
HtmlDocument *htdoc;

GtkWidget *html_view, *propertybox;
GtkListStore *store;
GtkCellRenderer *renderer;
GtkTreeViewColumn *column;
GConfClient *gc_client;

/// Filename of the XSLT stylesheet to transform TEI to HTML, usually tei2htm.xsl
char *stylesheetfn;

/// Filename of the curently opened dictionary
char *selected_filename;

/// If 1, the program will ask for a filename before saving the currently open dictionary
gboolean save_as_mode;

/// If true, something was modified
gboolean form_modified, file_modified;

/// Senses of the entry currently edited in the form view
GArray *senses;

/// Print XML dump of XML node @a n to stderr
void dump_node(xmlNodePtr n)
{
  xmlBufferPtr buf = xmlBufferCreate();
  int ret2 = xmlNodeDump(buf, teidoc, n, 0, 1);
  if(ret2 != -1)
    g_printerr("%s\n", xmlBufferContent(buf));
  if(buf) xmlBufferFree(buf);
}


///////////////////////////////////////////////////////////////
// thread related functions
// read also:
// file:/opt/gnome/share/gtk-doc/html/gdk/gdk-Threads.html
// file:/opt/gnome/share/gtk-doc/html/glib/glib-Threads.html
// gtk-faq ff.
// file:/home/micha/dict/t/gnome-things/gtk+-2.6.1/docs/faq/html/x482.html
// XXX the only thing the user should be able to do
// during evaluation of an XPath expression
// should be pressing the stop-button
///////////////////////////////////////////////////////////////

int finish_gui_update_thread;

/** Mutex to allow find_node_set_threaded() to be called only once
 * and make other calls return NULL
 */
GMutex *find_nodeset_mutex = NULL;

/** Mutex to protect initial and final access to thread_xpath_pcontext
 * from the XPath evaluation thread and the Stop button thread.
 */
GMutex *find_nodeset_pcontext_mutex = NULL;

xmlXPathParserContextPtr thread_xpath_pcontext;

/** Inside this thread no GTK+ functions should be called - they are ignored
 * since we don't have the global GTK+ lock.
 */
static void *
start_find_node_set_thread(void *private_data)
{
  const char *xpath = (const char *) private_data;
  //g_printerr("  find_node_set_thread: Calling find_node_set(%s, ...)... ", xpath);

  // creation and deletion of thread_xpath_pcontext in my_xmlXPathEvalExpression()
  // are protected through a find_nodeset_pcontext_mutex
  thread_xpath_pcontext = 0;

  xmlNodeSetPtr result = find_node_set(xpath, teidoc, &thread_xpath_pcontext);
  finish_gui_update_thread++;
 // g_printerr("  find_node_set_thread: ending\n");
  return (void *) result;
}


/// Button callback that stops currently running XPath evaluation
/** It works by setting an error code in the xmlXpathContext of the evaluation.
 *
 * This is how the XPath evaluation functions in FreeDict-Editor and libxml2 nest:
 *
 * find_node_set() ->
 *   xmlXPathEvalExpression() ->
 *     xmlXPathEvalExpr() ->
 *       xmlXPathRunEval() ->
 *         xmlXPathCompOpEval() -> CHECK_ERROR0
 *
 * CHECK_ERROR0 is a macro that checks an xmlXPathParserContextPtr pctxt->error.
 * If any error code is found there, the curently running evaluation is aborted
 * (cleanly, I hope).
 *
 * Since the pctxt is created in xmlXPathEvalExpression(), we had to reimplement
 * this function in my_xmlXPathEvalExpression() to be able to create a pctxt
 * which is accessible from the thread which receives the callback from the
 * Stop button click.
 */
void
on_stop_find_nodeset_clicked           (GtkButton       *button,
                                        gpointer         user_data)
{
  g_mutex_lock(find_nodeset_pcontext_mutex);
  if(thread_xpath_pcontext)
  {
    // it would be nice to modify libxml2 to create a new error code like
    // XPATH_EVALUATION_STOPPED_ERROR
    thread_xpath_pcontext->error = XPATH_EXPR_ERROR;
    g_printerr("Success: Error code set.\n");
  }
  g_mutex_unlock(find_nodeset_pcontext_mutex);
}


xmlNodeSetPtr find_node_set_threaded(const char *xpath, const xmlDocPtr doc)
{
  g_debug("find_node_set_threaded()");
  // return while an xpath match from another thread is being processed
  if(!g_mutex_trylock(find_nodeset_mutex)) return NULL;

  GtkWidget *stop =  glade_xml_get_widget(my_glade_xml, "stop_find_nodeset");
  gtk_widget_set_sensitive(stop, TRUE);

  finish_gui_update_thread = 0;
  GThread *thread = g_thread_create(start_find_node_set_thread, (gpointer) xpath, TRUE, NULL);

  while(!finish_gui_update_thread)
  {
    while(gtk_events_pending())
    {
      if(gtk_main_iteration()) finish_gui_update_thread++;
    }
    //g_debug("next round... finish_gui_update_thread=%i",
	//finish_gui_update_thread);
    g_thread_yield();
  }

  g_debug(" joining find_node_set thread");
  xmlNodeSetPtr result = g_thread_join(thread);

  gtk_widget_set_sensitive(stop, FALSE);

  g_mutex_unlock(find_nodeset_mutex);

  g_debug("finished find_nodeset_threaded");
  return result;
}


///////////////////////////////////////////////////////////////


/// Loads and opens the file given by @a filename
void myload(const char *filename)
{
  g_return_if_fail(filename);
  int subs = xmlSubstituteEntitiesDefault(1);
  g_debug("Substitution of external entities was %i.", subs);
  //int vali = xmlDoValidityCheckingDefaultValue;
  xmlDoValidityCheckingDefaultValue = 1;
  //fprintf(stderr, "Validity checking was %i.\n", vali);
  //int extd = xmlLoadExtDtdDefaultValue;
  //xmlLoadExtDtdDefaultValue = 1;
  //fprintf(stderr, "Load ext DTD was %i.\n", extd);

  xmlDocPtr d = xmlParseFile(filename);
  if(!d)
  {
    mystatus(_("Failed to load %s!"), filename);
    return;
  }

  setTeidoc(d);
  g_debug("Finished loading.");
  on_select_entry_changed(NULL, NULL);
}


/// Menu callback for Opening a New Document.

/** It will open an empty template dict.
 */
void
on_new1_activate                       (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  const char *location1 = PACKAGE_DATA_DIR "/" PACKAGE "/la1-la2.template.tei";
  const char *location2 = "data/la1-la2.template.tei";
  const char *location3 = "../data/la1-la2.template.tei";
  if(g_file_test(location1, G_FILE_TEST_EXISTS))
    myload(location1);
  else if(g_file_test(location2, G_FILE_TEST_EXISTS))
    myload(location2);
  else if(g_file_test(location3, G_FILE_TEST_EXISTS))
    myload(location3);
  else
  {
    GtkWidget *dialog = gtk_message_dialog_new (GTK_WINDOW(app1),
	GTK_DIALOG_DESTROY_WITH_PARENT,
	GTK_MESSAGE_ERROR,
	GTK_BUTTONS_CLOSE,
	_("Couldn't find dictionary template.  Checked locations: "
	  "'%s', '%s' and %s"), location1, location2, location3);
    gtk_dialog_run (GTK_DIALOG (dialog));
    gtk_widget_destroy (dialog);
    return;
  }
  if(selected_filename) g_free(selected_filename);
  selected_filename = NULL;
}


/// Toolbar callback to create a new file.

/// Activates the corresponding menu entry.
void
on_new_file_button_clicked             (GtkButton       *button,
                                        gpointer         user_data)
{
  on_new1_activate(NULL, NULL);
}


void add_tei_file_filters_to_file_chooser(GtkFileChooser *f)
{
  GtkFileFilter *teifilter = gtk_file_filter_new();
  GtkFileFilter *nofilter = gtk_file_filter_new();
  gtk_file_filter_set_name(teifilter, _("TEI Files"));
  gtk_file_filter_set_name(nofilter, _("All Files"));
  gtk_file_filter_add_pattern(teifilter, "*.tei");
  gtk_file_filter_add_pattern(nofilter, "*");
  gtk_file_chooser_add_filter(f, teifilter);
  gtk_file_chooser_add_filter(f, nofilter);
}


/// Menu callback
void
on_open1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  GtkWidget *dialog = gtk_file_chooser_dialog_new (_("Open File"),
      GTK_WINDOW(app1),
      GTK_FILE_CHOOSER_ACTION_OPEN,
      GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL,
      GTK_STOCK_OPEN, GTK_RESPONSE_ACCEPT,
      NULL);
  add_tei_file_filters_to_file_chooser(GTK_FILE_CHOOSER(dialog));
  if (gtk_dialog_run (GTK_DIALOG (dialog)) == GTK_RESPONSE_ACCEPT)
  {
    selected_filename = gtk_file_chooser_get_filename
      (GTK_FILE_CHOOSER (dialog));
    myload(selected_filename);
  }
  gtk_widget_destroy (dialog);
}


/// Callback for menu entry.  Saves file if it already has a name.
void
on_save1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  if(!selected_filename || !strlen(selected_filename))
    on_save_as1_activate(NULL, NULL);
  else mysave();
}


/// Callback for manu entry.  Opens save dialog.
void
on_save_as1_activate                   (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  GtkWidget *dialog = gtk_file_chooser_dialog_new (_("Save File"),
      GTK_WINDOW(app1),
      GTK_FILE_CHOOSER_ACTION_SAVE,
      GTK_STOCK_CANCEL, GTK_RESPONSE_CANCEL,
      GTK_STOCK_SAVE, GTK_RESPONSE_ACCEPT,
      NULL);
  gtk_file_chooser_set_do_overwrite_confirmation
    (GTK_FILE_CHOOSER (dialog), TRUE);
  add_tei_file_filters_to_file_chooser(GTK_FILE_CHOOSER(dialog));

  if(!selected_filename || !strlen(selected_filename))
  {
    // user_edited_a_new_document
    gtk_file_chooser_set_current_name
      (GTK_FILE_CHOOSER (dialog), _("New Dictionary.tei"));
  }
  else
    gtk_file_chooser_set_filename (GTK_FILE_CHOOSER (dialog),
	selected_filename);

  if (gtk_dialog_run (GTK_DIALOG (dialog)) == GTK_RESPONSE_ACCEPT)
  {
    if(selected_filename) g_free(selected_filename);
    selected_filename = gtk_file_chooser_get_filename
      (GTK_FILE_CHOOSER (dialog));
    mysave();
  }
  gtk_widget_destroy (dialog);
}


/// Called when the user wants to quit. Displays confirmation dialog if necessary.
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
    gint result = gtk_dialog_run(GTK_DIALOG (dialog));
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

  if(!sure) return TRUE;

  // cleanup
  if(find_nodeset_mutex) g_mutex_free(find_nodeset_mutex);
  if(find_nodeset_pcontext_mutex) g_mutex_free(find_nodeset_pcontext_mutex);
  gtk_main_quit();
  if(entry_stylesheet) xsltFreeStylesheet(entry_stylesheet);
  if(stylesheetfn) g_free(stylesheetfn);
  if(teidoc) xmlFreeDoc(teidoc);
  xsltCleanupGlobals();
  xmlCleanupParser();
  return FALSE;
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
  GtkWidget* focusw = gtk_window_get_focus(GTK_WINDOW(app1));
  GtkClipboard *clipboard = gtk_widget_get_clipboard(focusw, GDK_SELECTION_CLIPBOARD);
  if(GTK_IS_ENTRY(focusw))
    gtk_clipboard_set_text(clipboard, gtk_entry_get_text(GTK_ENTRY(focusw)), -1);
  else if(GTK_IS_TEXT_VIEW(focusw))
  {
    GtkTextBuffer *b = gtk_text_view_get_buffer(GTK_TEXT_VIEW(focusw));
    gtk_text_buffer_cut_clipboard(b, clipboard, TRUE);
  }
}


void
on_copy1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  GtkWidget* focusw = gtk_window_get_focus(GTK_WINDOW(app1));
  GtkClipboard *clipboard = gtk_widget_get_clipboard(focusw, GDK_SELECTION_CLIPBOARD);
  if(GTK_IS_ENTRY(focusw))
    gtk_clipboard_set_text(clipboard, gtk_entry_get_text(GTK_ENTRY(focusw)), -1);
  else if(GTK_IS_TEXT_VIEW(focusw))
  {
    GtkTextBuffer *b = gtk_text_view_get_buffer(GTK_TEXT_VIEW(focusw));
    gtk_text_buffer_copy_clipboard(b, clipboard);
  }
}

void entry_paste_received(GtkClipboard *clipboard, const gchar *text, gpointer user_data)
{
  GtkWidget *entry = GTK_WIDGET(user_data);
  gtk_entry_set_text(GTK_ENTRY(entry), text);
}

void
on_paste1_activate                     (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  GtkWidget* focusw = gtk_window_get_focus(GTK_WINDOW(app1));
  GtkClipboard *clipboard = gtk_widget_get_clipboard(focusw, GDK_SELECTION_CLIPBOARD);

  if(GTK_IS_ENTRY(focusw))
    gtk_clipboard_request_text(clipboard, entry_paste_received, focusw);
  else if(GTK_IS_TEXT_VIEW(focusw))
  {
    GtkTextBuffer *b = gtk_text_view_get_buffer(GTK_TEXT_VIEW(focusw));
    gtk_text_buffer_paste_clipboard(b, clipboard, NULL, TRUE);
  }
}


void
on_clear1_activate                     (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  g_debug("Not implemented.");
}


void
on_about1_activate                     (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  GtkWidget* about2 =
    glade_xml_get_widget(my_glade_xml, "about2");
  gtk_widget_show_all(about2);
}


// Toolbar callback.  Forwards to menu entry callback.
void
on_openbutton_clicked                  (GtkButton       *button,
                                        gpointer         user_data)
{
  on_open1_activate(NULL, NULL);
}


/// Sets the global GTK+ Input Method

/** @arg new_context_id The context ID to set. Something like "default" or "IPA".
 * @retval FALSE on error, eg. ID does not exist
 * @retval TRUE on success
 */
gboolean set_global_im_gtk_context_id(char *new_context_id)
{
   GtkEntry *e = GTK_ENTRY(glade_xml_get_widget(my_glade_xml, "entry2"));

  // bad, since actually im_context is private!
  GtkIMMulticontext *m = GTK_IM_MULTICONTEXT(e->im_context);

  GtkWidget *dummymenu = gtk_menu_new();
  gtk_im_multicontext_append_menuitems (m, GTK_MENU_SHELL(dummymenu));

  gboolean success = FALSE;

  void mycallback(GtkWidget *widget, gpointer data)
  {
    char *context_id = (char *) g_object_get_data(G_OBJECT(widget), "gtk-context-id");

    if(!context_id || !new_context_id ||
	strcmp(context_id, new_context_id)) return;

    // requested context id found
    gtk_menu_item_activate(GTK_MENU_ITEM(widget));
    success = TRUE;
  }

  gtk_container_foreach(GTK_CONTAINER(dummymenu), &mycallback, NULL);

  gtk_widget_destroy(dummymenu);
  return success;
}

/// Finds the currently active global GTK+ Input Method ID
/** The follwoing was an alternative approach:
 *	GtkEntry *e = GTK_ENTRY(glade_xml_get_widget(my_glade_xml, "entry2"));
 *	GtkIMMulticontext *m = GTK_IM_MULTICONTEXT(e->im_context);
 * Strangely, the following always printed gtk-im-context-simple, ie.  reports
 * the default IM would be used - which was not true:
 *	if(m) printf("e->im_context->context_id: %s\n", m->context_id);
 * We want the global_context_id, which is static in
 * gtk/gtkimmulticontext.c unfortunately, so we cannot access it directly.
 *
 * I wish GTK had the notion of local input methods.
 */
char *find_global_im_gtk_context_id(void)
{
  GtkEntry *e = GTK_ENTRY(glade_xml_get_widget(my_glade_xml, "entry2"));
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


int timeout_id = -1;

/** If the matching takes too long, this function could be called several
 * times.  That is why the timeout is removed upon entering the callback.
 */
gboolean on_select_timeout(gpointer data)
{
  g_debug("on_select_timeout()");
  gtk_timeout_remove(timeout_id);
  timeout_id = -1;

  const gchar* template = gtk_entry_get_text(GTK_ENTRY(
    glade_xml_get_widget(my_glade_xml, "xpath_entry")));

  // format string check: only one %s and many %% allowed
  const char *fscan = template;
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
	  return FALSE;
	}
      case '%':
	fscan = perc+2;
	continue;
      default:
	mystatus(_("Malformed XPath-Template. Only one %%s and "
	      "many %%%% allowed."));
	return FALSE;
    }
  }
  g_debug("XPath template passed check.");

  const gchar* select1 = gtk_entry_get_text(GTK_ENTRY(
	glade_xml_get_widget(my_glade_xml, "select_entry")));
  char select[400];
  g_snprintf(select, sizeof(select), template, select1);

  if(!store)
  {
    store = gtk_list_store_new(2, G_TYPE_STRING, G_TYPE_POINTER);
    gtk_tree_view_set_model(GTK_TREE_VIEW(
	glade_xml_get_widget(my_glade_xml, "treeview1")),
	GTK_TREE_MODEL(store));
  }
  else gtk_list_store_clear(store);

  xmlNodeSetPtr nodes = find_node_set_threaded(select, teidoc);

  if(!nodes || !nodes->nodeNr) mystatus(_("No matches."));
  else
  {
    mystatus(_("%i matching nodes"), nodes->nodeNr);

    GtkTreeIter i;
    xmlNodePtr *n;
    int j = 0;
    for(n = nodes->nodeTab; *n && j<nodes->nodeNr && j<50; n++, j++)
    {
      char orthline[200];
      entry_orths_to_string(*n, sizeof(orthline), orthline);
      gtk_list_store_append(store, &i);
      gtk_list_store_set(store, &i, 0, orthline, 1, *n, -1);
    }
    xmlXPathFreeNodeSet(nodes);
  }

  if(renderer) return FALSE;

  renderer = gtk_cell_renderer_text_new();
  column = gtk_tree_view_column_new_with_attributes(_("Matching Nodes"),
      renderer, "text", 0, NULL);
  gtk_tree_view_append_column(GTK_TREE_VIEW(
	glade_xml_get_widget(my_glade_xml, "treeview1")), column);

  return FALSE;
}


/// "Select" Input Field callback
/* The "Select" Input Field is there for the user to enter a string which will
 * be used in an XPath match to select the entries to be listed in Treeview1.
 * Since it doesn't make sense to start the expensive match operation after
 * every entered char, we wait for 500 ms and hope the user doesn't need more
 * time to find the next key :)
 */
void
on_select_entry_changed                (GtkEditable     *editable,
                                        gpointer         user_data)
{
  g_debug("on_select_entry_changed()");
  if(timeout_id!=-1) gtk_timeout_remove(timeout_id);
  timeout_id = gtk_timeout_add(500, on_select_timeout, NULL);
}


/// Treeview1 Row Double-Click Callback
/** Opens the entry corresponding to the double-clicked in the entry editor.
 */
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
  set_edited_node(e);
}


int sanity_treeview_remove_entry_pointers(xmlNodePtr n);

void replace_edited_node(xmlNodePtr new_node)
{
  g_return_if_fail(new_node);
  g_return_if_fail(edited_node);

  // replace old node element in teidoc
  xmlReplaceNode(edited_node, new_node);

  sanity_treeview_remove_entry_pointers(edited_node);
  xmlFree(edited_node);
  if(!file_modified)
  { file_modified = TRUE; on_file_modified_changed(); }

  set_edited_node(new_node);
  g_assert(edited_node == new_node);

  // update treeview1
  on_select_entry_changed(NULL, NULL);

  mystatus(_("Edit accepted."));
}


// returns success
gboolean save_textview1()
{
  GtkTextView *textview1 = GTK_TEXT_VIEW(
      glade_xml_get_widget(my_glade_xml, "textview1"));
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

  replace_edited_node(entryRoot);
  gtk_text_buffer_set_modified(b, FALSE);
  return TRUE;
}


void
on_save_button_clicked                 (GtkButton       *button,
                                        gpointer         user_data)
{
  on_save1_activate(NULL, NULL);
}


// for gettimeofday()
#include <sys/time.h>
#include <time.h>

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
    new_entry = xmlNewChild(bodyNode, NULL, (xmlChar *) "entry", (xmlChar *) "\n");

  // show in edit area
  set_edited_node(new_entry);

  if(gtk_notebook_get_current_page(
	GTK_NOTEBOOK(glade_xml_get_widget(my_glade_xml, "notebook1"))) == 1)
  {
    // copy text from "select" input field into orth field of new entry
    GtkWidget *entry1 = glade_xml_get_widget(my_glade_xml, "entry1");
    const gchar* select1 = gtk_entry_get_text(GTK_ENTRY(
	  glade_xml_get_widget(my_glade_xml, "select_entry")));
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
    g_debug("msec=%lli\n",
	new_entry_timestamps[current_new_entry_timestamp_index]);
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
    g_debug("sum of timestamps=%f valid=%i lowest=%lli\n",
	speed, valid, lowest);
    if(valid>1) speed = 60*60*1000.0 / (speed/(gdouble)valid - lowest);
    else speed = 0;
  }

  mystatus(_("New entry created and editable. Speed: %2.1f entries/hour"), speed);
}


/// Delete currently edited entry
void
on_delete_button_clicked               (GtkButton       *button,
                                        gpointer         user_data)
{
  g_return_if_fail(edited_node);

  // don't delete things that are no entries
  g_return_if_fail(!strcmp((char *) edited_node->name, "entry"));

  xmlUnlinkNode(edited_node);
  sanity_treeview_remove_entry_pointers(edited_node);
  xmlFree(edited_node);
  set_edited_node(NULL);

  if(!file_modified)
  { file_modified = TRUE; on_file_modified_changed(); }

  // update treeview1
  on_select_entry_changed(NULL, NULL);
}


void
on_add_new_entry1_activate             (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  on_new_entry_button_clicked(NULL, NULL);
}


void
on_delete_entry1_activate              (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  on_delete_button_clicked(NULL, NULL);
}


void
on_save_entry1_activate                (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  on_apply_button_clicked(NULL, NULL);
}


void
on_cancel_edit1_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  on_cancel_edit_button_clicked(NULL, NULL);
}


// returns whether saving was successful
gboolean save_form()
{
  if(!form_modified) return TRUE;
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

  replace_edited_node(modified_entry);
  return TRUE;
}


void on_form_modified_changed()
{
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "apply_button"),
      teidoc && form_modified);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "cancel_edit_button"),
      teidoc && form_modified);
}


void
on_notebook1_switch_page               (GtkNotebook     *notebook,
                                        GtkNotebookPage *page,
                                        guint            page_num,
                                        gpointer         user_data)
{
  // we can do this check usefully only since edited_node is temporarily set
  // to NULL in set_edited_node()
  if(!edited_node) return;

  // the user switched the view

  // XXX the following code shouldn't be in a notification function, since
  // it may have to prevent swiching

  if(page_num==1)
  {
    // XXX unconditional auto-save is bad here, we should better prevent
    // switching if saving fails

    // save contents of textview1
    save_textview1();

    // fill form
    if(!xml2form(edited_node, senses))
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
    if(edited_node && !save_form())
      mystatus(_("Saving form contents as XML failed :("));

    // fill textview1
    show_in_textview1(edited_node);
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
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "apply_button"),
      sensitive);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "cancel_edit_button"),
      sensitive);
}


void set_lock_dockitems_state(gboolean locked)
{
  // the docking classes are not documented in the libbonoboui docs
  // because the api is considered as unstable
  BonoboDock *bonobodock1 = BONOBO_DOCK(
      glade_xml_get_widget(my_glade_xml, "bonobodock1"));

  void on_lock_dockitems_list_callback2(gpointer data, gpointer user_data)
  {
    BonoboDockBandChild *child = (BonoboDockBandChild*) data;

    // see also /opt/gnome/include/libbonoboui-2.0/bonobo/bonobo-dock-item.h
    BonoboDockItem *item = 0;
    item = BONOBO_DOCK_ITEM(child->widget);
    g_return_if_fail(item);

    //g_debug("Name of this bonobo dock item: '%s'\n", item->name);

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
  g_list_foreach(bonobodock1->top_bands,
      on_lock_dockitems_list_callback, NULL);
  g_list_foreach(bonobodock1->bottom_bands,
      on_lock_dockitems_list_callback, NULL);
  g_list_foreach(bonobodock1->right_bands,
      on_lock_dockitems_list_callback, NULL);
  g_list_foreach(bonobodock1->left_bands,
      on_lock_dockitems_list_callback, NULL);
}

void on_lock_dockitems_toggled(GtkCheckMenuItem *item, gpointer user_data)
{
  gboolean locked = gtk_check_menu_item_get_active(item);
  // save state with gconf
  //
  char* key = gnome_gconf_get_app_settings_relative(NULL, "lock_dockitems");
  gconf_client_set_bool(gc_client, key, locked, NULL);
  g_free(key);

  // gconf will notify us in turn
}


void my_widget_set_visible(GtkWidget *w, gboolean visible)
{
  if(visible) gtk_widget_show(w);
  else gtk_widget_hide(w);
}


void on_view_html_toggled(GtkCheckMenuItem *item, gpointer user_data)
{
  gboolean new_state = gtk_check_menu_item_get_active(item);

  // save state with gconf
  char* key = gnome_gconf_get_app_settings_relative(NULL, "hide_html_preview");
  gconf_client_set_bool(gc_client, key, !new_state, NULL);
  g_free(key);

  // gconf will notify us in turn
}


void on_view_toolbar_toggled(GtkCheckMenuItem *item, gpointer user_data)
{
  gboolean new_state = gtk_check_menu_item_get_active(item);

  // save state with gconf
  char* key = gnome_gconf_get_app_settings_relative(NULL, "hide_toolbar");
  gconf_client_set_bool(gc_client, key, !new_state, NULL);
  g_free(key);

  // gconf will notify us in turn
}


// remember state, so new entry editor labels can be set visible or not
gboolean labels_visible = TRUE;

// this is normally called by our gconf notification handler
void set_view_labels_visible(gboolean visible)
{
  labels_visible = visible;
  my_widget_set_visible(glade_xml_get_widget(my_glade_xml,
	"select_label"), labels_visible);
  my_widget_set_visible(glade_xml_get_widget(my_glade_xml,
	"xpath_template_label"), labels_visible);
  my_widget_set_visible(glade_xml_get_widget(my_glade_xml,
	"orth_label"), labels_visible);
  my_widget_set_visible(glade_xml_get_widget(my_glade_xml,
	"pron_label"), labels_visible);
  my_widget_set_visible(glade_xml_get_widget(my_glade_xml,
	"pos_label"), labels_visible);
  my_widget_set_visible(glade_xml_get_widget(my_glade_xml,
	"num_label"), labels_visible);
  my_widget_set_visible(glade_xml_get_widget(my_glade_xml,
	"gen_label"), labels_visible);

  if(senses)
  {
    // for all senses
    int i;
    for(i = 0; i < senses->len; i++)
    {
      Sense s = g_array_index(senses, Sense, i);
      my_widget_set_visible(s.domain_label, labels_visible);
      my_widget_set_visible(s.register_label, labels_visible);
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
}


void on_view_labels_toggled(GtkCheckMenuItem *item, gpointer user_data)
{
  gboolean new_state = gtk_check_menu_item_get_active(item);
  if(labels_visible == new_state) return;

  // save state with gconf
  char* key = gnome_gconf_get_app_settings_relative(NULL, "hide_labels");
  gconf_client_set_bool(gc_client, key, !new_state, NULL);
  g_free(key);

  // gconf will notify us in turn
}


/** Tries to show corresponding entry. Since there might be several matches,
 * set select_entry and display preview of the first match.
 */
static void on_link_clicked(HtmlDocument *doc, const gchar *url, gpointer data)
{
  g_debug("on_link_clicked: url='%s'", url);
  g_return_if_fail(url);

  // get url
  GnomeVFSURI* vfs_uri = gnome_vfs_uri_new(url);
  gchar *str_url = gnome_vfs_uri_to_string(vfs_uri, GNOME_VFS_URI_HIDE_TOPLEVEL_METHOD);
  g_debug("on_link_clicked: str_url='%s'", str_url);
  gnome_vfs_uri_unref(vfs_uri);

  // decode url
  char *unesc_str_url = xmlURIUnescapeString(str_url, 0, NULL);
  g_free(str_url);
  g_debug("on_link_clicked: unesc_str_url='%s'", unesc_str_url);

  // XXX better: find exact matches only
  gtk_entry_set_text(GTK_ENTRY(
	  glade_xml_get_widget(my_glade_xml, "select_entry")), unesc_str_url);

  xmlFree(unesc_str_url);

  GtkTreePath *path = gtk_tree_path_new_first();
  gtk_tree_view_set_cursor(GTK_TREE_VIEW(glade_xml_get_widget(my_glade_xml, "treeview1")),
      path, NULL, FALSE);
  gtk_tree_path_free(path);
}

Values *load_values_from_gconf(const char *relative_key,
    const Values *default_values)
{
  g_return_val_if_fail(relative_key && default_values, NULL);
  char *key = gnome_gconf_get_app_settings_relative(NULL, relative_key);
  GSList *list = gconf_client_get_list(gc_client,
      key, GCONF_VALUE_STRING, NULL);
  g_free(key);
  Values *v;
  if(list && g_slist_length(list)>0)
  {
    v = GSList2Values(list);
    g_printerr(_("Loaded %s from GConf.\n"), relative_key);
    my_g_slist_free_all(list);
  }
  else
  {
    v = (Values *) default_values;
    g_printerr(_("Using builtin default %s.\n"), relative_key);
  }
  return v;
}

// forward declaration
static void on_gconf_client_notify(GConfClient *client, guint cnxn_id,
    GConfEntry *entry, gpointer user_data);

void
on_app1_show                           (GtkWidget       *widget,
                                        gpointer         user_data)
{
  g_debug("on_app1_show()");
  find_nodeset_mutex = g_mutex_new();
  find_nodeset_pcontext_mutex = g_mutex_new();

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

  // load settings
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

      g_printerr(_("Key was empty. Using default: %s\n"), stylesheetfn);
    }
    else g_printerr(_("Using stylesheet filename from gconf: %s\n"), stylesheetfn);
  }

  char* key = gnome_gconf_get_app_settings_relative(NULL, "hide_labels");
  gconf_client_notify(gc_client, key);
  g_free(key);

  key = gnome_gconf_get_app_settings_relative(NULL, "hide_toolbar");
  gconf_client_notify(gc_client, key);
  g_free(key);

  key = gnome_gconf_get_app_settings_relative(NULL, "lock_dockitems");
  gconf_client_notify(gc_client, key);
  g_free(key);

  key = gnome_gconf_get_app_settings_relative(NULL, "hide_html_preview");
  gconf_client_notify(gc_client, key);
  g_free(key);

  pos_values = load_values_from_gconf("pos_values", pos_values_default);
  num_values = load_values_from_gconf("num_values", num_values_default);
  domain_values = load_values_from_gconf("domain_values",
      domain_values_default);
  register_values = load_values_from_gconf("register_values",
      register_values_default);
  xr_values = load_values_from_gconf("xr_values", xr_values_default);
  gen_values = load_values_from_gconf("gen_values", gen_values_default);

  if(!entry_template_doc)
  {
    xmlDoValidityCheckingDefaultValue = 0;
    const char *fname1 = PACKAGE_DATA_DIR "/" PACKAGE "/entry-template.xml";
    const char *fname2 = "data/entry-template.xml";
    const char *fname3 = "../data/entry-template.xml";
    if(g_file_test(fname1, G_FILE_TEST_EXISTS))
      entry_template_doc = xmlParseFile(fname1);
    else if(g_file_test(fname2, G_FILE_TEST_EXISTS))
      entry_template_doc = xmlParseFile(fname2);
    else if(g_file_test(fname3, G_FILE_TEST_EXISTS))
      entry_template_doc = xmlParseFile(fname3);
    else
    {
      GtkWidget *dialog = gtk_message_dialog_new (GTK_WINDOW(app1),
	  GTK_DIALOG_DESTROY_WITH_PARENT,
	  GTK_MESSAGE_ERROR,
	  GTK_BUTTONS_CLOSE,
	  _("Couldn't find entry template.  Checked locations: "
	    "'%s', '%s' and %s"), fname1, fname2, fname3);
      gtk_dialog_run (GTK_DIALOG (dialog));
      gtk_widget_destroy (dialog);
    }
    if(!entry_template_doc)
      mystatus(_("Failed to parse entry template!"));
  }

  if(!entry_stylesheet)
  {
    entry_stylesheet =
      xsltParseStylesheetFile((xmlChar *) stylesheetfn);
    if(!entry_stylesheet)
    {
      mystatus(_("Could not load entry stylesheet %s. HTML Preview won't work!"),
	  stylesheetfn);
    }
    else
    {
      html_view = html_view_new();
      gtk_paned_pack2 (GTK_PANED (glade_xml_get_widget(
	      my_glade_xml, "editor_preview_vpaned")), html_view, FALSE, TRUE);
      htdoc = html_document_new();
      g_signal_connect((gpointer) htdoc, "link_clicked",
	  G_CALLBACK(on_link_clicked), NULL);
      html_view_set_document(HTML_VIEW(html_view), htdoc);
      gtk_widget_show(html_view);
    }
  }

  if(!senses) senses = g_array_new(FALSE, TRUE, sizeof(Sense));

  GtkTextView *textview1 = GTK_TEXT_VIEW(glade_xml_get_widget(my_glade_xml, "textview1"));
  GtkTextBuffer* b = gtk_text_view_get_buffer(textview1);

  // XXX ugly
  gtk_text_buffer_create_tag(b, "instructions",
//      "foreground", "blue",
//      "scale", PANGO_SCALE_X_LARGE,
      "wrap-mode", GTK_WRAP_WORD,
      NULL);

  // we could connect to this signal in glade-2 by entering the signal name
  // manually, but glade-2 should offer it in its "Select Signal" dialog
  // XXX fix glade-2, but glade.gnome.org says they work on glade3 :(
  g_signal_connect((gpointer) b, "modified-changed",
      G_CALLBACK(on_textview1_modified_changed), NULL);

  // the following signal handlers are not connected by glade-2,
  // even though the signal handler can be set in the property editor
/*
   g_signal_connect ((gpointer) glade_xml_get_widget(my_glade_xml, "view_html"), "toggled",
      G_CALLBACK (on_view_html_toggled), NULL);
  g_signal_connect ((gpointer) glade_xml_get_widget(my_glade_xml, "lock_dockitems"), "toggled",
      G_CALLBACK (on_lock_dockitems_toggled), NULL);
  g_signal_connect ((gpointer) glade_xml_get_widget(my_glade_xml, "view_labels"), "toggled",
      G_CALLBACK (on_view_labels_toggled), NULL);
  g_signal_connect ((gpointer) glade_xml_get_widget(my_glade_xml, "view_toolbar"), "toggled",
      G_CALLBACK (on_view_toolbar_toggled), NULL);
*/
  setTeidoc(NULL);

  // XXX the accel paths don't work :(
  // maybe we just have to make menus with accelerators???
  // how to make an accel configuration dialog?
  create_menu(
      GTK_OPTION_MENU(glade_xml_get_widget(my_glade_xml, "pos_optionmenu")),
      "<" PACKAGE ">/Headword/pos",
      pos_values);

  create_menu(
      GTK_OPTION_MENU(glade_xml_get_widget(my_glade_xml, "num_optionmenu")),
      "<" PACKAGE ">/Headword/num",
      num_values);

  create_menu(
      GTK_OPTION_MENU(glade_xml_get_widget(my_glade_xml, "gen_optionmenu")),
      "<" PACKAGE ">/Headword/gen",
      gen_values);

  //  gtk_menu_set_accel_path(
//      GTK_MENU(gtk_option_menu_get_menu(
//	  GTK_OPTION_MENU(glade_xml_get_widget(my_glade_xml, "num_optionmenu")))),
//      "<" PACKAGE ">/num_optionmenu");

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
  //register_freedict_xpath_extension_functions();
}


void update_html_preview(xmlNodePtr entry)
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

  const char *err = N_("Error converting entry to HTML!");
  if(!html_entry)
  {
    mystatus(_(err));
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

  if(bytes == -1 || !txt)
    html_document_write_stream(htdoc, _(err), sizeof(_(err)));
  else html_document_write_stream(htdoc, (char *) txt, len);
  if(txt) xmlFree(txt);
  html_document_close_stream(htdoc);
  xmlFreeDoc(html_entry);
}


void
on_apply_button_clicked                (GtkButton       *button,
                                        gpointer         user_data)
{
  switch(gtk_notebook_get_current_page(GTK_NOTEBOOK(
	  glade_xml_get_widget(my_glade_xml, "notebook1"))))
  {
    case 0:
      save_textview1();
      break;

    case 1:
      // save contents of form
      if(!save_form()) mystatus(_("Saving form contents as XML failed."));
      else gtk_widget_grab_focus(glade_xml_get_widget(my_glade_xml, "select_entry"));
      break;

    default:
      g_assert_not_reached();
  }

  update_html_preview(edited_node);
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
  set_edited_node(edited_node);
}


void
on_treeview1_cursor_changed            (GtkTreeView     *treeview,
                                        gpointer         user_data)
{
  // return if HTML preview off
  if(!gtk_check_menu_item_get_active(GTK_CHECK_MENU_ITEM(
	  glade_xml_get_widget(my_glade_xml, "view_html")))) return;

  // get currently selected entry
  GtkTreeView *tv = GTK_TREE_VIEW(glade_xml_get_widget(my_glade_xml, "treeview1"));
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
  update_html_preview(e);
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

  if(!strncmp((char *) data->data, "file://", 7))
  {
    static char myfilename[200];
    char *end = strstr((char *) data->data + 7, "\r\n");
    if(end)
    {
      *end = 0;
      if(selected_filename) g_free(selected_filename);
      selected_filename = g_strdup((char *) data->data + 7);
      g_debug("Trying to load '%s'", myfilename);
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
  g_return_if_fail(teidoc);

  // find header node
  xmlNodePtr h = find_single_node("/TEI.2/teiHeader", teidoc);
  g_return_if_fail(h);

  set_edited_node(h);
}

void
on_view_keyboard_layout_activate       (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  // XXX get group and shift level from a dialog

  gchar *xkbprintpath = g_find_program_in_path("xkbprint");
  if(!xkbprintpath)
  {
    mystatus(_("Failed to find 'xkbprint' in path."));
    return;
  }
  gchar *gvpath = g_find_program_in_path("gv");
  if(!gvpath)
  {
    mystatus(_("Failed to find 'gv' in path."));
    return;
  }

  const char commandline[] =
    "xkbprint -color -lg 1 -ll 1 :0 - | gv --orientation=seascape -";
  if(gnome_execute_shell(NULL, commandline) == -1)
  {
    mystatus(_("Failed to show keyboard layout with command: %s"), commandline);
    return;
  }
  mystatus(_("Done: %s"), commandline);
}

void
on_help_menuitem_activate (GtkMenuItem     *menuitem,
    gpointer         user_data)
{
  GError *error;
  if(gnome_help_display(PACKAGE ".xml", NULL,  &error)) return;

  // display error
  g_printerr(G_STRLOC ": gnome_help_display() failed: %s\n",
      error->message);
}


///////////////////////////////////////////////////////////////////////////
// spelling code
///////////////////////////////////////////////////////////////////////////

#ifdef HAVE_LIBASPELL
#include <aspell.h>

AspellConfig *c;
AspellSpeller *s;
AspellDocumentChecker *checker;
AspellCanHaveError *possible_err;
struct AspellStringMap *replace_all_map;

GtkWidget *scw;
GtkListStore *spell_sugg_store;
GtkCellRenderer *spell_sugg_renderer;

xmlNodeSetPtr spell_nodes;
/// Index into @a spell_nodes. Updates should be done using set_spell_current_node_idx()
int spell_current_node_idx;
xmlNodePtr spell_current_node;
int replacements_made;

#ifndef NOCKR
AspellToken token;
gboolean in_node;
int diff;
char *word_begin;
gboolean replaced_something;
/// input for DocumentChecker
/** It is a static array to capture replacements longer than the original text. */
gchar spell_content[500];
char misspelled_token_str[400];
#else
gchar** spell_current_words;
int spell_current_word_idx;
gchar *iso88591text;
#endif

#define check_for_config_error(config)                            \
  if (aspell_config_error(config) != 0) {                         \
    g_printerr("Error: %s\n", aspell_config_error_message(config));   \
  }

static void set_replacements_made(unsigned int value)
{
  g_return_if_fail(scw);
  replacements_made = value;
  char str[40];
  g_snprintf(str, sizeof(str), "%i", value);
  gtk_label_set_text(GTK_LABEL(glade_xml_get_widget(my_glade_xml, "replacements_counter_label")), str);
}

static void set_spell_current_node_idx(unsigned int value)
{
  spell_current_node_idx = value;

  // update progressbar
  gtk_progress_bar_set_fraction(GTK_PROGRESS_BAR(
	glade_xml_get_widget(my_glade_xml, "spell_progressbar")),
      (gdouble) spell_current_node_idx /
      (gdouble) xmlXPathNodeSetGetLength(spell_nodes));
}
#endif

static void spell_getsuggestions(char *word)
{
#ifdef HAVE_LIBASPELL
  GtkTreeView *sugg_treeview = GTK_TREE_VIEW(
      glade_xml_get_widget(my_glade_xml, "suggestions_treeview"));

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
  while((sugg = aspell_string_enumeration_next(elements)))
  {
    // XXX remove this... ISO-8859-1 -> UTF-8
    gchar *utf8text;
    gsize length = strlen(sugg);
    GError *error = NULL;

    utf8text = g_convert(sugg, length, "UTF-8", "ISO-8859-1",
	NULL, NULL, &error);
    if(error != NULL)
    {
      g_printerr("Couldn't convert string from ISO-8859-1 to UTF-8: '%s'. Ignoring.\n",
	 sugg);
      g_error_free(error);
    }

    // add to suggestion list
    gtk_list_store_append(spell_sugg_store, &i);// init i
    gtk_list_store_set(spell_sugg_store, &i, 0, utf8text, -1);
  }

  if(!spell_sugg_renderer)
  {
    spell_sugg_renderer = gtk_cell_renderer_text_new();
    GtkTreeViewColumn *spell_sugg_column = gtk_tree_view_column_new_with_attributes
      ("Suggestions", spell_sugg_renderer, "text", 0, NULL);
    gtk_tree_view_append_column(sugg_treeview, spell_sugg_column);
  }
  delete_aspell_string_enumeration(elements);

  // select first replacement
  GtkTreePath *p = gtk_tree_path_new_first();
  // on_suggestions_treeview_cursor_changed() will be called in effect
  gtk_tree_view_set_cursor(sugg_treeview, p, NULL, FALSE);
  gtk_tree_path_free(p);
#endif
}


/** This should be called for each word of the current node.  It returns TRUE,
 * if a user decision is awaited and FALSE when a correct word was encountered.
 * It expects a next word to be available and returns FALSE if there isn't. But
 * that condition should be checked by the caller.
 *
 * XXX When we use AspellDocumentChecker exclusively, we can rename this to
 * spell_handle_current_misspelling
 */
gboolean spell_handle_current_word()
{
#ifdef HAVE_LIBASPELL
  g_return_val_if_fail(s, FALSE);
#ifndef NOCKR
  g_return_val_if_fail(in_node, FALSE);
  g_return_val_if_fail(token.len, FALSE);

  // display current misspelling
  word_begin = spell_content + token.offset + diff;
  g_debug("%.*s*%.*s*%s",
      (int)(token.offset + diff), spell_content,
      (int)token.len, word_begin,
      word_begin + token.len);

  snprintf(misspelled_token_str, sizeof(misspelled_token_str), "%.*s", (int)token.len, word_begin);

  // test whether "replace all" was selected for this word
  const char *replace_all_replacement = aspell_string_map_lookup(
      replace_all_map, misspelled_token_str);
  if(replace_all_replacement)
  {
    // XXX
    g_debug("Found replacement: %s", replace_all_replacement);
    // return FALSE;
  }

  gtk_entry_set_text(GTK_ENTRY(glade_xml_get_widget(my_glade_xml, "misspelled_word_entry")),
      misspelled_token_str);
  spell_getsuggestions(misspelled_token_str);
#else
  g_return_val_if_fail(spell_current_words &&
      spell_current_words[spell_current_word_idx], FALSE);

  char *w = spell_current_words[spell_current_word_idx];
  //g_print("Checking word %i: '%s'... ", spell_current_word_idx, w);

  int l = strlen(w);
  gboolean spell_saved_punct = FALSE;
  char spell_saved_char;
  if(l)
  {
    spell_saved_char = *(w + l -1);
    if(g_ascii_ispunct(spell_saved_char))
    {
      *(w + l -1) = 0;
      spell_saved_punct = TRUE;
    }
  }

  int correct = aspell_speller_check(s, w, -1);
  //g_print(" correct=%i\n", correct);

  if(spell_saved_punct)
    *(w + l -1) = spell_saved_char;

  if(correct) return FALSE;

  g_print("Incorrect: word %i %s\n", spell_current_word_idx, w);

  gtk_entry_set_text(GTK_ENTRY(glade_xml_get_widget(my_glade_xml, "misspelled_word_entry")),
      spell_current_words[spell_current_word_idx]);
  spell_getsuggestions(spell_current_words[spell_current_word_idx]);
#endif // NOCKR

  // show entry containing the misspelling in html preview
  // look for an entry ancestor
  xmlNodePtr n = spell_current_node;
  while(n && n->name && strcmp((char *) n->name, "entry"))
   n = n->parent;
  if(n && n->type==XML_ELEMENT_NODE)
  {
    update_html_preview(n);
    // XXX mark misspelled_token_str in preview
  }

#endif // HAVE_LIBASPELL
  // now wait for user decision (replace, ignore etc.)
  return TRUE;
}


/** This should be called for each text node to be spellchecked.
 * It uses AspellDocumentChecker, so aspell does the word splitting
 * and punctuation char handling (I think).
 *
 * @retval TRUE if a user decision is awaited
 * @retval FALSE if there are no more words in the current node or
 *               when there is no current node or it is not a text node,
 *		 but these last two conditions are expected to be checked
 *		 by the caller.
 */
gboolean spell_handle_current_node(void)
{
#ifdef HAVE_LIBASPELL
  g_return_val_if_fail(spell_current_node, FALSE);
  g_return_val_if_fail(xmlNodeIsText(spell_current_node), FALSE);

#ifndef NOCKR
  g_return_val_if_fail(checker, FALSE);
  if(!in_node)
#else
  if(!spell_current_words)
#endif
  {
    xmlChar *spell_current_content = xmlNodeGetContent(spell_current_node);

    // UTF-8 -> ISO-8859-1
    // XXX also convert things for session/personal dict
    gsize length = strlen((char *) spell_current_content);
    GError *error = NULL;

    char *iso88591text = g_convert((char *) spell_current_content, length, "ISO-8859-1",
       	"UTF-8", NULL, NULL, &error);
    if(error != NULL)
    {
      g_printerr("Couldn't convert string from UTF-8 to ISO-8859-1: '%s'. Ignoring.\n",
	 spell_current_content);
      g_error_free(error);
    }
    g_strlcpy(spell_content, iso88591text, sizeof(spell_content));
    g_free(iso88591text);

#ifndef NOCKR
    aspell_document_checker_process(checker, spell_content, -1);
    diff = 0;
    in_node = TRUE;
    replaced_something = FALSE;
#else
    spell_current_words = g_strsplit(spell_content, " ", 40);
    //g_warning("after split words[0]='%s'", spell_current_words[0]);
    spell_current_word_idx = 0;
#endif
  }

#ifndef NOCKR
  while(token = aspell_document_checker_next_misspelling(checker),
        token.len != 0)
  {
    if(spell_handle_current_word()) return TRUE;// wait for user decision
  }

  if(replaced_something)
  {
    xmlChar *old_content = xmlNodeGetContent(spell_current_node);
    g_print("Node content: old='%s' new='%s'\n", old_content, spell_content);
    xmlNodeSetContent(spell_current_node, (xmlChar *) spell_content);
 }
  in_node = FALSE;
#else
  g_return_val_if_fail(spell_current_words, FALSE);// split failed

  while(spell_current_words[spell_current_word_idx])
  {
    if(spell_handle_current_word()) return TRUE;// wait for user decision
    spell_current_word_idx++;// next word
  }

  g_strfreev(spell_current_words);
  spell_current_words = 0;
#endif
#endif
  return FALSE;
}


// XXX fde crashes if aspell installed but no dict
void get_new_checker_speller()
{
#ifdef HAVE_LIBASPELL
  g_return_if_fail(scw);
  g_return_if_fail(c);

  if(checker) { delete_aspell_document_checker(checker); checker=0; }
  if(s) { delete_aspell_speller(s); s=0; }

  char *true_false = "false";
  if(gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(
	glade_xml_get_widget(my_glade_xml, "accept_runtogether_checkbutton")))) true_false = "true";
  aspell_config_replace(c, "run-together", true_false);
  check_for_config_error(c);

  // new_aspell_speller() takes much time
  possible_err = new_aspell_speller(c);
  if(aspell_error_number(possible_err) != 0)
  {
    puts(aspell_error_message(possible_err));
    return;
  }
  else s = to_aspell_speller(possible_err);
  g_return_if_fail(s);

  // Set up the document checker
  possible_err = new_aspell_document_checker(s);
  if(aspell_error(possible_err) != 0)
  {
    g_printerr("Error: %s\n", aspell_error_message(possible_err));
    return;
  }
  checker = to_aspell_document_checker(possible_err);
  in_node = FALSE;

#if 0
  // dump config details
  // 1 = include extra
  struct AspellKeyInfoEnumeration *keyis = aspell_config_possible_elements(c, 1);

  while(!aspell_key_info_enumeration_at_end(keyis))
  {
    const struct AspellKeyInfo *keyi = aspell_key_info_enumeration_next(keyis);
    if(!keyi) continue;// XXX not nice/clean
    g_printerr("%s=", keyi->name);
    switch(keyi->type)
    {
      case AspellKeyInfoString:
	g_printerr("%s", aspell_config_retrieve(c, keyi->name));
	break;
      case AspellKeyInfoInt:
	g_printerr("%i", aspell_config_retrieve_int(c, keyi->name));
	break;
      case AspellKeyInfoBool:
	g_printerr("%ib", aspell_config_retrieve_bool(c, keyi->name));
	break;
      case AspellKeyInfoList:
	g_printerr("(list)");
	break;
	//int aspell_config_retrieve_list(c, keyi->name, struct AspellMutableContainer * lst);
    }
    g_printerr(" (default: %s)\n", keyi->def);
  }
  delete_aspell_key_info_enumeration(keyis);
#endif
#endif
}


void on_spell_dict_menu_selection_done(GtkMenuShell *menushell, gpointer user_data)
{
#ifdef HAVE_LIBASPELL
  g_debug("on_spell_dict_menu_selection_done()");
  g_return_if_fail(c);// AspellConfig

  // in case we got called from spell_continue_check()
  if(!menushell) menushell = GTK_MENU_SHELL(gtk_option_menu_get_menu(
	GTK_OPTION_MENU(glade_xml_get_widget(my_glade_xml, "spell_dict_optionmenu"))));

  GtkWidget* l = gtk_menu_get_active(GTK_MENU(menushell));

  // returns also when no dicts available
  g_return_if_fail(l);

  char *code = g_object_get_data(G_OBJECT(l), "aspell-code");
  char *jargon = g_object_get_data(G_OBJECT(l), "aspell-jargon");
  char *size = g_object_get_data(G_OBJECT(l), "aspell-size");

  g_printerr("Selecting aspell dictionary: lang=%s jargon=%s size=%s\n",
      code, jargon, size);

  if(code) aspell_config_replace(c, "lang", code);
  check_for_config_error(c);
  if(jargon) aspell_config_replace(c, "jargon", jargon);
  check_for_config_error(c);
  if(size) aspell_config_replace(c, "size", size);
  check_for_config_error(c);

  get_new_checker_speller();
#endif
}


void spell_continue_check()
{
#ifdef HAVE_LIBASPELL
  // try to get a speller
  if(!s) on_spell_dict_menu_selection_done(NULL, NULL);
  g_return_if_fail(s);// speller reqd

  while(1)
  {
    spell_current_node =
      xmlXPathNodeSetItem(spell_nodes, spell_current_node_idx);

    if(!spell_current_node) break;// finished spellcheck

    if(!xmlNodeIsText(spell_current_node))
    {
      g_debug("Node %i is no text node. Skip.", spell_current_node_idx);
      set_spell_current_node_idx(spell_current_node_idx+1);
      continue;
    }

    if(spell_handle_current_node()) return;// user decision awaited

    set_spell_current_node_idx(spell_current_node_idx+1);
  }

  // inactivate all widgets except "close" button
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_replace_button"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_replace_all_button"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_ignore_button"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_ignore_all_button"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_add_button"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "suggestions_treeview"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "replacement_entry"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_headwords_radiobutton"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_translations_radiobutton"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_orth_checkbutton"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_tr_checkbutton"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_eg_checkbutton"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_eg_tr_checkbutton"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_dict_optionmenu"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "accept_runtogether_checkbutton"), FALSE);

  mystatus(_("Finished Spellcheck."));
#endif
}


void spell_query_nodes()
{
#ifdef HAVE_LIBASPELL
  // build XPath query
  gboolean orth = gtk_toggle_button_get_active(
      GTK_TOGGLE_BUTTON(glade_xml_get_widget(my_glade_xml, "spell_orth_checkbutton")));
  gboolean tr = gtk_toggle_button_get_active(
      GTK_TOGGLE_BUTTON(glade_xml_get_widget(my_glade_xml, "spell_tr_checkbutton")));
  gboolean eg = gtk_toggle_button_get_active(
      GTK_TOGGLE_BUTTON(glade_xml_get_widget(my_glade_xml, "spell_eg_checkbutton")));
  gboolean eg_tr = gtk_toggle_button_get_active(
      GTK_TOGGLE_BUTTON(glade_xml_get_widget(my_glade_xml, "spell_eg_tr_checkbutton")));

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
  g_print("query: '%s'...", query);

  spell_nodes = find_node_set(query, teidoc, NULL);
  g_print(" %i nodes\n", xmlXPathNodeSetGetLength(spell_nodes));

  set_spell_current_node_idx(0);
  in_node = FALSE;

  g_return_if_fail(xmlXPathNodeSetGetLength(spell_nodes));
#endif
}


void
on_spell_check1_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
#ifdef HAVE_LIBASPELL
  if(scw)
  {
    gtk_window_present(GTK_WINDOW(scw));
    return;
  }

  scw = glade_xml_get_widget(my_glade_xml, "spellcheck_window");
  g_signal_connect(scw, "destroy", G_CALLBACK (gtk_widget_destroyed), &scw);
  gtk_widget_show_all(scw);

  set_replacements_made(0);
  GtkWidget* spell_dict_menu = gtk_menu_new();

  g_signal_connect(spell_dict_menu, "selection-done",
      G_CALLBACK(on_spell_dict_menu_selection_done), NULL);

  c = new_aspell_config();
  const char *c_lang = aspell_config_retrieve(c, "lang");

#define catch_aspell_error_and_return_if_fail(condition) \
  if(aspell_config_error(c) != 0) {                      \
    g_printerr("aspell error: %s\n",                     \
      aspell_config_error_message(c));                   \
    g_return_if_fail(condition); }

  catch_aspell_error_and_return_if_fail(c_lang)
  const char *c_jargon = aspell_config_retrieve(c, "jargon");
  catch_aspell_error_and_return_if_fail(c_jargon)
  const char *c_size = aspell_config_retrieve(c, "size");
  catch_aspell_error_and_return_if_fail(c_size);
  catch_aspell_error_and_return_if_fail(1)

  // This requires aspell 0.60.3 (0.50.3 didn't have utf-8 encoding support yet)
  aspell_config_replace(c, "encoding", "UTF-8");

  // fill dictionaries option menu
  // for all aspell dictionaries
  AspellDictInfoList* l = get_aspell_dict_info_list(c);
  AspellDictInfoEnumeration *e = aspell_dict_info_list_elements(l);
  guint i;
  for(i=0; !aspell_dict_info_enumeration_at_end(e); i++)
  {
    const AspellDictInfo *d = aspell_dict_info_enumeration_next(e);
    char item[100];
    snprintf(item, sizeof(item), _("%s, size=%s"),
        d->name, d->size_str);

    // save details so we can use them for aspell_config_replace()
    gchar *code2 = g_strndup(d->code, 30);
    gchar *jargon2 = g_strndup(d->jargon, 30);
    gchar *size_str2 = g_strndup(d->size_str, 30);
    g_assert(code2 !=0 && jargon2 != 0 && size_str2 != 0);

    GtkWidget *mitem = gtk_menu_item_new_with_label(item);
    gtk_widget_show(mitem);
    g_object_set_data(G_OBJECT(mitem), "aspell-code", code2);
    g_object_set_data(G_OBJECT(mitem), "aspell-jargon", jargon2);
    g_object_set_data(G_OBJECT(mitem), "aspell-size", size_str2);
    gtk_menu_shell_append(GTK_MENU_SHELL(spell_dict_menu), mitem);

    // preselect aspell chosen dict
    if(!strcmp(d->code,   c_lang) &&
       !strcmp(d->jargon, c_jargon) &&
       !strcmp(d->size_str, c_size)) gtk_option_menu_set_history(
	 GTK_OPTION_MENU(glade_xml_get_widget(my_glade_xml, "spell_dict_optionmenu")), i);
 }
  delete_aspell_dict_info_enumeration(e);
  gtk_option_menu_set_menu(GTK_OPTION_MENU(glade_xml_get_widget(my_glade_xml,
	  "spell_dict_optionmenu")), spell_dict_menu);

  spell_query_nodes();

  replace_all_map = new_aspell_string_map();
  spell_continue_check();
#else
  mystatus(_("This binary of FreeDict-Editor was compiled without aspell support."));
#endif // HAVE_LIBASPELL
}


void
on_spell_replace_button_clicked        (GtkButton       *button,
                                        gpointer         user_data)
{
#ifdef HAVE_LIBASPELL

#ifdef NOCKR
  g_return_if_fail(spell_current_words && spell_current_words[spell_current_word_idx]);
#endif

  GtkWidget *entry = glade_xml_get_widget(my_glade_xml, "replacement_entry");
  char *replacement = g_strdup(gtk_entry_get_text(GTK_ENTRY(entry)));
  g_return_if_fail(replacement);

#ifndef NOCKR
  unsigned int repl_len = strlen(replacement);
  g_print("Replacing with %s\n", replacement);

  // Replace the misspelled word with the replacement
  diff += repl_len - token.len;
  // If replacement is longer or shorter, move following text accodingly.
  // For this the additional space had to be allocated in advance.
  // A buffer overflow check is missing here!
  memmove(word_begin + repl_len, word_begin + token.len,
      strlen(word_begin + token.len) + 1);
  memcpy(word_begin, replacement, repl_len);
  replaced_something = TRUE;

  aspell_speller_store_replacement(s, misspelled_token_str, -1, replacement, -1);
#else

  char *old = spell_current_words[spell_current_word_idx];

  if(!strcmp(old, replacement))
  {
    g_print(_("There is no use in replacing a misspelled word with itself.\n"));
    g_free(replacement);
    return;
  }

  g_print("Replacing %s with %s\n", old, replacement);
  // replacing one word with two creates problem here
  // -> split again?
  spell_current_words[spell_current_word_idx] = replacement;
  aspell_speller_store_replacement(s, old, -1, replacement, -1);
  g_free(old);

  gchar* new_content = g_strjoinv(" ", spell_current_words);
  g_print("New node content: '%s'\n", new_content);

  g_return_if_fail(spell_current_node);
  xmlChar *spell_current_content = xmlNodeGetContent(spell_current_node);
  g_print("Old node content: '%s'\n", spell_current_content);

  xmlNodeSetContent(spell_current_node, new_content);
  g_free(new_content);

#endif
  set_replacements_made(replacements_made+1);
  if(!file_modified) { file_modified = TRUE; on_file_modified_changed(); }
  spell_continue_check();
#endif
}


void
on_spell_replace_all_button_clicked    (GtkButton       *button,
                                        gpointer         user_data)
{
#ifdef HAVE_LIBASPELL
  GtkWidget *entry = glade_xml_get_widget(my_glade_xml, "replacement_entry");
  char *replacement = g_strdup(gtk_entry_get_text(GTK_ENTRY(entry)));
  g_return_if_fail(replacement);

  on_spell_replace_button_clicked(NULL, NULL);

  g_return_if_fail(replace_all_map);

#ifndef NOCKR
  int res = aspell_string_map_insert(replace_all_map, misspelled_token_str, replacement);
  if(!res)
    g_printerr("'%s' already exists in replace_all_map. Insert request rejected.\n", misspelled_token_str);
#else
  char *old = spell_current_words[spell_current_word_idx];
  int res = aspell_string_map_insert(replace_all_map, old, replacement);
  if(!res)
    g_printerr("'%s' already exists in replace_all_map. Insert request rejected.\n", old);
#endif
#endif
}


void
on_spell_ignore_button_clicked         (GtkButton       *button,
                                        gpointer         user_data)
{
#ifdef NOCKR
  // handle next word
  spell_current_word_idx++;
#endif
  spell_continue_check();
}


void
on_spell_ignore_all_button_clicked     (GtkButton       *button,
                                        gpointer         user_data)
{
#ifdef HAVE_LIBASPELL
  g_return_if_fail(s);
#ifndef NOCKR
  int ret = aspell_speller_add_to_session(s, misspelled_token_str, -1);
  g_print("Storing '%s' in session word list gave %i (0 = error, 1 = success).\n",
      misspelled_token_str, ret);
#else
  g_return_if_fail(spell_current_words);
  g_return_if_fail(spell_current_words[spell_current_word_idx]);

  int ret = aspell_speller_add_to_session(s, spell_current_words[spell_current_word_idx], -1);
  g_print("Storing '%s' in session word list gave %i (0 = error, 1 = success).\n",
      spell_current_words[spell_current_word_idx], ret);
#endif
  if(!ret) g_printerr("Aspell error: %s\n", aspell_speller_error_message(s));
  spell_continue_check();
#endif
}


void
on_spell_add_button_clicked            (GtkButton       *button,
                                        gpointer         user_data)
{
#ifdef HAVE_LIBASPELL
  g_return_if_fail(s);
#ifndef NOCKR
  int ret = aspell_speller_add_to_personal(s, misspelled_token_str, -1);
  g_print("Storing '%s' in personal word list gave %i (0 = error, 1 = success).\n",
      misspelled_token_str, ret);
#else
  g_return_if_fail(spell_current_words);
  g_return_if_fail(spell_current_words[spell_current_word_idx]);

  int ret = aspell_speller_add_to_personal(s, spell_current_words[spell_current_word_idx], -1);
  g_print("Storing '%s' in personal word list gave %i (0 = error, 1 = success).\n",
      spell_current_words[spell_current_word_idx], ret);
#endif
  if(!ret) g_printerr("Aspell error: %s\n", aspell_speller_error_message(s));

  spell_continue_check();
#endif
}


void
on_spell_close_button_clicked          (GtkButton       *button,
                                        gpointer         user_data)
{
#ifdef HAVE_LIBASPELL

#ifdef NOCKR
  if(spell_current_words)
  {
    g_strfreev(spell_current_words);
    spell_current_words = 0;
  }
#endif
  // XXX for aspell docs: it doesn't save the session wordlist, does it?
  // it should save only personal and main word list (out of which the main word list
  // is usually not changed(?))
  int ret = aspell_speller_save_all_word_lists(s);
  g_printerr("aspell_speller_save_all_word_lists() gave %i\n", ret);

  if(spell_nodes) { xmlXPathFreeNodeSet(spell_nodes); spell_nodes=0; }

  delete_aspell_string_map(replace_all_map);
  if(checker) { delete_aspell_document_checker(checker); checker=0; }
  if(s) { delete_aspell_speller(s); s=0; }
  if(c) { delete_aspell_config(c); c=0; }

  // XXX only delete this if cast to speller failed?
  //delete_aspell_can_have_error(possible_err);
  //g_warning("deleted possible_err");

  spell_sugg_store = 0;
  spell_sugg_renderer = 0;
  if(scw) gtk_widget_destroy(scw);
  //g_warning("destroyed spellcheck window");
#endif
}


// additionally, the radiobuttons could be put into
// inconsistent state when a strange combination
// of togglebuttons is created
void
on_spell_headwords_radiobutton_toggled (GtkToggleButton *togglebutton,
                                        gpointer         user_data)
{
#ifdef HAVE_LIBASPELL
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	glade_xml_get_widget(my_glade_xml, "spell_orth_checkbutton")), TRUE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	glade_xml_get_widget(my_glade_xml, "spell_tr_checkbutton")), FALSE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	glade_xml_get_widget(my_glade_xml, "spell_eg_checkbutton")), TRUE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	glade_xml_get_widget(my_glade_xml, "spell_eg_tr_checkbutton")), FALSE);
  spell_query_nodes();
#endif
}


void
on_spell_translations_radiobutton_toggled
                                        (GtkToggleButton *togglebutton,
                                        gpointer         user_data)
{
#ifdef HAVE_LIBASPELL
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	glade_xml_get_widget(my_glade_xml, "spell_orth_checkbutton")), FALSE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	glade_xml_get_widget(my_glade_xml, "spell_tr_checkbutton")), TRUE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	glade_xml_get_widget(my_glade_xml, "spell_eg_checkbutton")), FALSE);
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(
	glade_xml_get_widget(my_glade_xml, "spell_eg_tr_checkbutton")), TRUE);
  spell_query_nodes();
#endif
}


void
on_accept_runtogether_checkbutton_toggled
                                        (GtkToggleButton *togglebutton,
                                        gpointer         user_data)
{
  get_new_checker_speller();
}


/// Replace misspelled word with double-clicked suggestion
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
#ifdef HAVE_LIBASPELL
  // get currently selected entry
  g_return_if_fail(treeview);
  GtkTreePath *path;
  GtkTreeViewColumn *dummycol;
  gtk_tree_view_get_cursor(treeview, &path, &dummycol);

  char *sugg;
  // no suggestion in treeview
  if(!path) sugg = "";
  else
  {
    GtkTreeIter iter;
    gboolean ret = gtk_tree_model_get_iter(GTK_TREE_MODEL(spell_sugg_store), &iter, path);
    g_assert(ret);
    gtk_tree_model_get(GTK_TREE_MODEL(spell_sugg_store), &iter, 0, &sugg, -1);
    g_return_if_fail(sugg);
  }

  // put selected suggestion into replacement entry
  GtkWidget *entry = glade_xml_get_widget(my_glade_xml, "replacement_entry");
  gtk_entry_set_text(GTK_ENTRY(entry), sugg);
#endif
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
    propertybox = glade_xml_get_widget(my_glade_xml, "propertybox1");

    // XXX checkbox to use default or not

    // populate fields by taking the current variable values and
    // putting them into the input fields
    gnome_file_entry_set_filename(
	GNOME_FILE_ENTRY(glade_xml_get_widget(my_glade_xml,
	    "stylesheet_fileentry")),
	stylesheetfn);
    // XXX make input field insensitive if key not writable

    gtk_label_set_text(GTK_LABEL(glade_xml_get_widget(my_glade_xml,
	    "editer_default_name_label")), g_get_real_name());

    gtk_label_set_text(GTK_LABEL(glade_xml_get_widget(my_glade_xml,
	    "editer_default_email_label")), g_get_user_name());
    // XXX ++ @localhost
  }

  gtk_widget_show_all(propertybox);
}


/// GConf Callback that was registered at application startup
static void on_gconf_client_notify(GConfClient *client, guint cnxn_id,
    GConfEntry *entry, gpointer user_data)
{
  g_return_if_fail(entry);
  g_debug("on_gconf_client_notify for key %s\n", entry->key);
  if(!strcmp(entry->key, "/apps/freedict-editor/pos_values"))
  {
    my_free_values_array(&pos_values);
    pos_values = load_values_from_gconf("pos_values", pos_values_default);
    return;
  }
  if(!strcmp(entry->key, "/apps/freedict-editor/hide_labels"))
  {
    gboolean show = !gconf_client_get_bool(gc_client, entry->key, NULL);
    GtkCheckMenuItem *item = GTK_CHECK_MENU_ITEM(
	glade_xml_get_widget(my_glade_xml, "view_labels"));
    gtk_check_menu_item_set_active(item, show);
    set_view_labels_visible(show);
    return;
  }
  if(!strcmp(entry->key, "/apps/freedict-editor/hide_toolbar"))
  {
    gboolean show = !gconf_client_get_bool(gc_client, entry->key, NULL);
    GtkCheckMenuItem *item = GTK_CHECK_MENU_ITEM(
	glade_xml_get_widget(my_glade_xml, "view_toolbar"));
    gtk_check_menu_item_set_active(item, show);
    GtkWidget *toolbar_bonobodockitem =
      glade_xml_get_widget(my_glade_xml, "toolbar_bonobodockitem");
    my_widget_set_visible(toolbar_bonobodockitem, show);
    return;
  }
  if(!strcmp(entry->key, "/apps/freedict-editor/lock_dockitems"))
  {
    gboolean lock = gconf_client_get_bool(gc_client, entry->key, NULL);
    GtkCheckMenuItem *item = GTK_CHECK_MENU_ITEM(
	glade_xml_get_widget(my_glade_xml, "lock_dockitems"));
    gtk_check_menu_item_set_active(item, lock);
    set_lock_dockitems_state(lock);
    return;
  }
  if(!strcmp(entry->key, "/apps/freedict-editor/hide_html_preview"))
  {
    gboolean show = !gconf_client_get_bool(gc_client, entry->key, NULL);
    GtkCheckMenuItem *item = GTK_CHECK_MENU_ITEM(
	glade_xml_get_widget(my_glade_xml, "view_html"));
    gtk_check_menu_item_set_active(item, show);
    my_widget_set_visible(GTK_WIDGET(html_view), show);
    return;
  }
  // the following code is for demonstration purposes only
  if(!gconf_entry_get_value(entry))
  {
    g_debug("key was unset\n");
  }
  else
  {
    if(gconf_entry_get_value(entry)->type == GCONF_VALUE_STRING)
    {
      g_debug("STRING: %s\n",
	  gconf_value_get_string(gconf_entry_get_value(entry)));
    }
    else
    {
      g_debug("Not STRING type\n");
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
      GNOME_FILE_ENTRY(glade_xml_get_widget(my_glade_xml,
	  "stylesheet_fileentry")), TRUE); // file must exist
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
  g_printerr(G_STRLOC ": gnome_help_display() failed: %s\n",
      error->message);
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

/// Columns in the Sanity Check TreeView
enum
{
  CHECK_ENABLED_COLUMN = 0,
  IS_TITLE_ROW,
  TITLE_COLUMN,
  HEADWORDS_COLUMN,
  ENTRY_POINTER_COLUMN,
  STRUCT_CHECK_POINTER_COLUMN,
  N_SANITY_COLUMNS
};

/// Groups Information for Sanity Checks
struct sanity_check
{
  const char *title;///< Title to display
  const char *select;///< XPath expression that returns a set of &lt;entry> elements
};

/*
   xmlns:fd="http://freedict.org/freedict-editor

if u know the languages better (usually trans-pos is not encoded in the same TEI file):
 orth-pos has to match trans-pos

XXX store check name, xpath and enabled status with gconf and use the following table
only as default
*/

static struct sanity_check sanity_checks[] = {
  { N_("Missing Part-of-Speech"),
    "//entry[ not(gramGrp/pos) ]" },
  { N_("Nouns without Gender"),
    "//entry[ gramGrp/pos='n' and not(gramGrp/gen) ]" },
  { N_("Notes with Question Marks"),
    "//entry[ .//note[contains(., '?')] ]" },
  { N_("Empty Headwords"),
    "//entry[ form/orth[ normalize-space()='' ] or count(form/orth)<1 ]" },
  { N_("Empty Body"),
    "//entry[ *[ not(form) and normalize-space()='' ] ]" },

  // too slow
  { N_("Homographs of same Part-of-Speech"),
    "//entry[ form/orth = preceding-sibling::entry/form/orth | "
      "following-sibling::entry/form/orth and "
      "gramGrp/pos = preceding-sibling::entry/gramGrp/pos | "
      "following-sibling::entry/gramGrp/pos ]" },
  { N_("Broken Cross-References"),
    "//entry[ count(sense/xr/ref) != count( sense/xr/ref "
      "[../../../preceding-sibling::entry/form/orth | "
      "../../../following-sibling::entry/form/orth = .]) ]" },

  { N_("Multiple Headwords"),
    "//entry[ count(form/orth) > 1 ]" },
  { N_("\"to \" before verbs (only useful for English, checks tr)"),
    "//entry[ starts-with(gramGrp/pos, 'v') and starts-with(.//tr, 'to ') ]" },
  { N_("\"to \" before verbs (only useful for English, checks orth)"),
    "//entry[ starts-with(gramGrp/pos, 'v') and starts-with(form/orth, 'to ') ]" },
  { N_("Unbalanced braces"),
    "//entry[ fd:unbalanced-braces(.//orth | .//tr | .//note | .//def | .//q) ]" },
  { NULL } };

GtkWidget* sanity_window;
GtkTreeStore *sanity_store;


/// Remove entries from sanity_treeview which point to entry @a n
/** This function should be called whenever an entry is deleted.
 * @return number of removed rows
 */
int sanity_treeview_remove_entry_pointers(xmlNodePtr n)
{
  // in case the sanity window is not open
  if(!sanity_store) return 0;

  //g_printerr("sanity_treeview_remove_entry_pointers(%x)\n", n);

  int removed = 0;

  gboolean sanity_treeview_remove_entry_pointers_callback(GtkTreeModel *model,
      GtkTreePath *path, GtkTreeIter *iter, gpointer data)
  {
    xmlNodePtr e;
    gboolean is_title_row;
    gtk_tree_model_get(GTK_TREE_MODEL(sanity_store), iter,
	IS_TITLE_ROW, &is_title_row,
	ENTRY_POINTER_COLUMN, &e, -1);

    // FALSE means to continue walking the model
    //g_printerr("\t %x %i", e, e!=n);
    if(is_title_row || e!=n) return FALSE;

    // XXX not sure whether deleting from this callback is safe
    gtk_tree_store_remove(sanity_store, iter);
    removed++;
    return FALSE;
  }

  gtk_tree_model_foreach(GTK_TREE_MODEL(sanity_store),
      sanity_treeview_remove_entry_pointers_callback, NULL);
  //g_printerr("Removed %i rows\n", removed);
  return removed;
}


/// Opens corresponding entry in entry editor
/** called after double-click on a row
 */
void
on_sanity_treeview_row_activated       (GtkTreeView     *treeview,
                                        GtkTreePath     *path,
                                        GtkTreeViewColumn *column,
                                        gpointer         user_data)
{
  GtkTreeIter iter;
  gboolean ret = gtk_tree_model_get_iter(GTK_TREE_MODEL(sanity_store), &iter, path);
  g_return_if_fail(ret);
  xmlNodePtr e;
  gtk_tree_model_get(GTK_TREE_MODEL(sanity_store), &iter,
      ENTRY_POINTER_COLUMN, &e, -1);

  // header columns have no associated entry
  if(!e) return;

  // If e has been deleted already the pointer is not NULL yet, which can
  // led to a null pointer exception in (or below) set_edited_node().
  // Therefore, on entry delete/modify _remove rows with the invalid pointer_
  // using sanity_treeview_remove_entry_pointers()!
  set_edited_node(e);
}


/// Called after single-click on a row
void
on_sanity_treeview_cursor_changed      (GtkTreeView     *treeview,
                                        gpointer         user_data)
{
  // return if HTML preview off
  if(!gtk_check_menu_item_get_active(GTK_CHECK_MENU_ITEM(
	  glade_xml_get_widget(my_glade_xml, "view_html")))) return;

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
  update_html_preview(e);
}


void sanity_perform_check(const struct sanity_check *check, gboolean enabled)
{
  g_return_if_fail(check);
  g_return_if_fail(check->select);
  g_return_if_fail(teidoc);
  g_return_if_fail(sanity_store);

  int nr = 0;
  xmlNodeSetPtr matches = NULL;
  if(enabled)
  {
    g_printerr("Checking for: %s\n       using: %s...", check->title, check->select);

    // run in a thread, so GUI can update
    matches = find_node_set_threaded(check->select, teidoc);
    if(matches) nr = matches->nodeNr;
    g_printerr(" %i matches.\n", nr);
  }
  else g_printerr("Skipping '%s'.\n", check->title);

  // print number of matches in TITLE_COLUMN
  char title_string[99];
  g_snprintf(title_string, sizeof(title_string), _("%1$s (%2$i matches)"),
      _(check->title), nr);
  GtkTreeIter child_i, root_i;
  gtk_tree_store_append(sanity_store, &root_i, NULL);
  gtk_tree_store_set(sanity_store, &root_i,
      CHECK_ENABLED_COLUMN, enabled,
      IS_TITLE_ROW, TRUE,
      TITLE_COLUMN, title_string,
      STRUCT_CHECK_POINTER_COLUMN, check,
      -1);

  if(!enabled || !matches) return;

  // for first 50 matching entries
  int j = 0;
  xmlNodePtr *n;
  for(j=0, n=matches->nodeTab; *n && j<matches->nodeNr && j<50; n++, j++)
  {
    char headwords[100];
    entry_orths_to_string(*n, sizeof(headwords), headwords);
    gtk_tree_store_append(sanity_store, &child_i, &root_i);
    gtk_tree_store_set(sanity_store, &child_i,
	IS_TITLE_ROW, FALSE,
	HEADWORDS_COLUMN, headwords,
	ENTRY_POINTER_COLUMN, *n,
	-1);
  }

  // add "..."
  if(j==50)
  {
    gtk_tree_store_append(sanity_store, &child_i, &root_i);
    gtk_tree_store_set(sanity_store, &child_i,
	IS_TITLE_ROW, FALSE,
	HEADWORDS_COLUMN, "...",
	-1);
  }
}


void on_sanity_check_column_toggled(GtkCellRendererToggle *cell_renderer,
    gchar *path_string,
    gpointer user_data)
{
  GtkTreeIter iter, child_i;
  GtkTreePath *path = gtk_tree_path_new_from_string(path_string);
  gboolean ret = gtk_tree_model_get_iter(GTK_TREE_MODEL(sanity_store), &iter, path);
  g_return_if_fail(ret);
  gboolean enabled;
  struct sanity_check *check;
  gtk_tree_model_get(GTK_TREE_MODEL(sanity_store), &iter,
      STRUCT_CHECK_POINTER_COLUMN, &check,
      CHECK_ENABLED_COLUMN, &enabled, -1);
  enabled = !enabled;
  gtk_tree_store_set(sanity_store, &iter,
      CHECK_ENABLED_COLUMN, enabled, -1);
  gtk_tree_path_free(path);

  if(enabled)
  {
    // perform check
    sanity_perform_check(check, enabled);
    return;
  }

  // return if no children exist
  if(!gtk_tree_model_iter_children(GTK_TREE_MODEL(sanity_store),
	&child_i, &iter)) return;

  // remove found matches
  while(gtk_tree_store_remove(sanity_store, &child_i)) {};
  // XXX update title
}


void
on_sanity_window_show                  (GtkWidget       *widget,
                                        gpointer         user_data)
{
  // all checks
  struct sanity_check *check = sanity_checks;
  while(check->title)
  {
    // XXX fetch whether check enabled from gconf
    sanity_perform_check(check, TRUE);
    check++;

    while(gtk_events_pending()) gtk_main_iteration_do(FALSE);
  }
  mystatus(_("Sanity checks performed."));
}


// menu entry callback that will open the sanity check window
void
on_sanity_check_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data)
{
  if(sanity_window)
  {
    gtk_window_present(GTK_WINDOW(sanity_window));
    return;
  }

  sanity_window = glade_xml_get_widget(my_glade_xml, "sanity_window");
  // NULL window variable when sanity_window is closed
  g_signal_connect(sanity_window, "destroy", G_CALLBACK (gtk_widget_destroyed), &sanity_window);

  GtkTreeView *sanity_tree_view = GTK_TREE_VIEW(
      glade_xml_get_widget(my_glade_xml, "sanity_treeview"));
  if(!sanity_store)
  {
    sanity_store = gtk_tree_store_new(
	N_SANITY_COLUMNS,
	G_TYPE_BOOLEAN,  /* Whether the Check is Enabled */
	G_TYPE_BOOLEAN,  /* Whether the Row is a Title Row */
	G_TYPE_STRING,   /* Name of Sanity Check */
	G_TYPE_STRING,   /* Headwords of matching entries */
	G_TYPE_POINTER,  /* xmlNodePtr to the entry */
	G_TYPE_POINTER   /* struct sanity_check * */
	);
  }
  else gtk_tree_store_clear(sanity_store);
  gtk_tree_view_set_model(sanity_tree_view, GTK_TREE_MODEL(sanity_store));

  GtkCellRenderer *renderer;
  GtkTreeViewColumn *column;

  renderer = gtk_cell_renderer_toggle_new();
  // check boxes should be shown only for check title rows, thus the "visible" property
  // is FALSE for others
  column = gtk_tree_view_column_new_with_attributes(
      _("Check Enabled?"), renderer,
      "active", CHECK_ENABLED_COLUMN,
      "visible", IS_TITLE_ROW, NULL);
  gtk_tree_view_append_column(sanity_tree_view, column);
  g_signal_connect((gpointer) renderer, "toggled",
      G_CALLBACK(on_sanity_check_column_toggled), NULL);

  renderer = gtk_cell_renderer_text_new();
  column = gtk_tree_view_column_new_with_attributes(
      _("Check Name"), renderer, "text", TITLE_COLUMN,
      "visible", IS_TITLE_ROW, NULL);
  gtk_tree_view_append_column(sanity_tree_view, column);

  renderer = gtk_cell_renderer_text_new();
  column = gtk_tree_view_column_new_with_attributes(
      _("Matching Entries"), renderer, "text", HEADWORDS_COLUMN, NULL);
  gtk_tree_view_append_column(sanity_tree_view, column);

  // XXX gtk_tree_view_unset_rows_drag_dest(sanity_tree_view);
}


//////////////////////////////////////////////////////////////////////////////
// maybe uncategorized code follows (usually new callbacks generated by glade)
//////////////////////////////////////////////////////////////////////////////


