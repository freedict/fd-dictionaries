#include "utils.h"

// for PACKAGE_NAME
#include "config.h"

// for lookup_widget()
#include "support.h"

// for fill_form()
#include "entryedit.h"


// remember to use "%%" in the format string to output a literal '%'
void mystatus(const char *format, ...)
{
  va_list args;
  gchar buffer[200];
  va_start(args, format);
  g_vsnprintf(buffer, 200, format, args);
  gnome_appbar_set_status(GNOME_APPBAR(lookup_widget(app1, "appbar1")), buffer);
  va_end(args);
}


// shows the XML dump of n in textview1
void show_in_textview1(const xmlNodePtr n)
{
  xmlBufferPtr buf = xmlBufferCreate();
  int ret2 = xmlNodeDump(buf, teidoc, n, 0, 1);
  g_assert(ret2 != -1);

  GtkTextView *textview1 = GTK_TEXT_VIEW(lookup_widget(app1, "textview1"));

  GtkTextBuffer* b = gtk_text_view_get_buffer(textview1);
  gtk_text_buffer_set_text(b, xmlBufferContent(buf), -1);
  xmlBufferFree(buf); 
  gtk_text_buffer_set_modified(b, FALSE);

  // XXX switch to XML view?
}


// side effect: changes the edit mode (XML or Form)
// maybe we should try form mode only option "Always try Form mode" enabled
void set_edited_entry(const xmlNodePtr e)
{
  GtkWidget *nb1 = lookup_widget(app1, "notebook1");
  gboolean sensitive = e ? TRUE : FALSE; 
  gtk_widget_set_sensitive(nb1, sensitive);
  gtk_widget_set_sensitive(lookup_widget(app1, "delete_button"), sensitive);

  // XXX maybe we should refuse to set a new edited_entry when
  // the currently edited one is not saved yet (or try to auto-save it)
  // this should ease the problem of on_notebook1_switch_page()
  // that it has to prevent switching if auto-save fails. 
  // but then, how to handle the user switching to the other view?
  
  // temporarily set edited_entry to NULL so on_notebook1_switch_page()
  // doesn't disturb us
  edited_entry = NULL;

  if(e)
  {
//    switch(gtk_notebook_get_current_page(GTK_NOTEBOOK(nb1)))
//    {
//      case 0: show_in_textview1(e);
//	      break;
//      case 1:
	      if(!xml2form(e, senses))
	      {
		show_in_textview1(e);
		gtk_notebook_set_current_page(GTK_NOTEBOOK(nb1), 0);
	      }
	      else
		gtk_notebook_set_current_page(GTK_NOTEBOOK(nb1), 1);
//	      break;
//      default:
//	      g_printerr("Unknown page number %i for notebook1!\n",
//		  gtk_notebook_get_current_page(GTK_NOTEBOOK(nb1)));
//    } // switch
  }
  else
  {
    GtkTextView *textview1 = GTK_TEXT_VIEW(lookup_widget(app1, "textview1"));
    GtkTextBuffer* b = gtk_text_view_get_buffer(textview1);
    // XXX make a wizard out of this?
    // should show only "No XML chunk currently edited."
    char text[] =
       	"1. Open a TEI file\n"
	"2. Modify the XPath select expression to match\n"
        "\tthe entries you desire to edit\n"
	"3. Double-click on an entry headword in the list\n"
        "\tof matching entries to the right!";
    gtk_text_buffer_set_text(b, text, -1);
    GtkTextIter start, end;
    gtk_text_buffer_get_iter_at_offset(b, &start, 0);
    gtk_text_buffer_get_iter_at_offset(b, &end, sizeof(text));
    gtk_text_buffer_apply_tag_by_name(b, "instructions", &start, &end);
  }
  
  edited_entry = e;
  if(form_modified) { form_modified = FALSE; on_form_modified_changed(); }
}


void on_file_modified_changed()
{   
  gtk_widget_set_sensitive(lookup_widget(app1, "save_button"),
      file_modified);
  gtk_widget_set_sensitive(lookup_widget(app1, "save1"), file_modified);
  gtk_widget_set_sensitive(lookup_widget(app1, "save_as1"), file_modified);
}


void setTeidoc(const xmlDocPtr t)
{
  gboolean sensitive = t ? TRUE : FALSE;
  file_modified = FALSE;
  gtk_widget_set_sensitive(lookup_widget(app1, "save_button"), FALSE);
  gtk_widget_set_sensitive(lookup_widget(app1, "save1"), FALSE);
  gtk_widget_set_sensitive(lookup_widget(app1, "save_as1"), FALSE);
  gtk_widget_set_sensitive(lookup_widget(app1, "new_entry_button"), sensitive);
  gtk_widget_set_sensitive(lookup_widget(app1, "select_entry"), sensitive);
  gtk_widget_set_sensitive(lookup_widget(app1, "spell_check1"), sensitive);
  gtk_widget_set_sensitive(lookup_widget(app1, "new_file_button"), !t);
  gtk_widget_set_sensitive(lookup_widget(app1, "new1"), !t);
  gtk_window_set_title(GTK_WINDOW(app1),
      (t && selected_filename) ? selected_filename : PACKAGE_NAME);
  teidoc = t;
  set_edited_entry(NULL);
}

    
void mysave(void)
{
  g_return_if_fail(teidoc);
  int ret = xmlSaveFile(selected_filename, teidoc);
  if(ret==-1)
  {
    mystatus("Saving to %s failed.", selected_filename); 
  }

  if(file_modified)
  { file_modified = FALSE; on_file_modified_changed(); }

  mystatus("Saved.");
}
