/** @file
 * @brief Utility functions for the Graphical User Inferface
 */

#include "utils.h"

// for PACKAGE_NAME
#include "config.h"

#include <glade/glade.h>
/// GladeXML object of the application to access widgets
extern GladeXML *my_glade_xml;

// for fill_form()
#include "entryedit.h"


// remember to use "%%" in the format string to output a literal '%'
void mystatus(const char *format, ...)
{
  va_list args;
  gchar buffer[200];
  va_start(args, format);
  g_vsnprintf(buffer, 200, format, args);
  gnome_appbar_set_status(GNOME_APPBAR(glade_xml_get_widget(my_glade_xml, "appbar1")), buffer);
  va_end(args);
}


// shows the XML dump of n in textview1
void show_in_textview1(const xmlNodePtr n)
{
  xmlBufferPtr buf = xmlBufferCreate();
  int ret2 = xmlNodeDump(buf, teidoc, n, 0, 1);
  g_assert(ret2 != -1);

  // XXX make textview1 global var to save lookups
  GtkTextView *textview1 = GTK_TEXT_VIEW(glade_xml_get_widget(my_glade_xml, "textview1"));

  GtkTextBuffer* b = gtk_text_view_get_buffer(textview1);
  gtk_text_buffer_set_text(b, (char *) xmlBufferContent(buf), -1);
  xmlBufferFree(buf); 
  gtk_text_buffer_set_modified(b, FALSE);

  // XXX make sure notebook1 shows page 0 (XML view)
}


void on_file_modified_changed();
void on_form_modified_changed();

// side effect: changes the edit mode (XML or Form)
// maybe we should try form mode only when option "Always try Form mode" enabled
void set_edited_node(const xmlNodePtr n)
{
  // XXX nb1 could be a global var inited at startup
  GtkWidget *nb1 = glade_xml_get_widget(my_glade_xml, "notebook1");
  gtk_widget_set_sensitive(nb1, n!=NULL);

  gboolean is_entry = n && !strcmp((char *) n->name, "entry");
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "delete_button"), is_entry);

  // XXX maybe we should refuse to set a new edited_node when
  // the currently edited one is not saved yet (or try to auto-save it)
  // this should ease the problem of on_notebook1_switch_page()
  // that it has to prevent switching if auto-save fails. 
  // but then, how to handle the user switching to the other view?
  
  // temporarily set edited_node to NULL so on_notebook1_switch_page()
  // doesn't disturb us
  edited_node = NULL;

  // en-/disable switching to Form View
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "form_view_label"), is_entry);
  
  if(n)
  {
    if(!is_entry || !xml2form(n, senses))
    {
      show_in_textview1(n);
      gtk_notebook_set_current_page(GTK_NOTEBOOK(nb1), 0);
    }
    else
      gtk_notebook_set_current_page(GTK_NOTEBOOK(nb1), 1);
  }
  else
  {
    GtkTextView *textview1 = GTK_TEXT_VIEW(glade_xml_get_widget(my_glade_xml, "textview1"));
    GtkTextBuffer* b = gtk_text_view_get_buffer(textview1);
    // XXX make a wizard out of this?
    // should show only "No XML chunk currently edited."
    char text[] =
       	N_("1. Open a TEI file\n\
2. Modify the XPath select expression to match\n\
\tthe entries you desire to edit\n\
3. Double-click on an entry headword in the list\n\
\tof matching entries to the right!");
    gtk_text_buffer_set_text(b, _(text), -1);
    GtkTextIter start, end;
    gtk_text_buffer_get_iter_at_offset(b, &start, 0);
    gtk_text_buffer_get_iter_at_offset(b, &end, sizeof(text));
    gtk_text_buffer_apply_tag_by_name(b, "instructions", &start, &end);
  }
  
  edited_node = n;
  if(form_modified) { form_modified = FALSE; on_form_modified_changed(); }
}


void on_file_modified_changed()
{   
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "save_button"),
      file_modified);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "save1"), file_modified);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "save_as1"), file_modified);
}


void setTeidoc(const xmlDocPtr t)
{
  gboolean sensitive = t ? TRUE : FALSE;
  file_modified = FALSE;
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "save_button"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "save1"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "save_as1"), FALSE);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "new_entry_button"), sensitive);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "select_entry"), sensitive);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "spell_check1"), sensitive);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "new_file_button"), !t);
  gtk_widget_set_sensitive(glade_xml_get_widget(my_glade_xml, "new1"), !t);
  gtk_window_set_title(GTK_WINDOW(app1),
      (t && selected_filename) ? selected_filename : PACKAGE_NAME);
  teidoc = t;
  set_edited_node(NULL);
}

    
void mysave(void)
{
  g_return_if_fail(teidoc);
  int ret = xmlSaveFile(selected_filename, teidoc);
  if(ret==-1)
  {
    mystatus(_("Saving to %s failed."), selected_filename); 
  }

  if(file_modified)
  { file_modified = FALSE; on_file_modified_changed(); }

  mystatus(_("Saved."));
}
