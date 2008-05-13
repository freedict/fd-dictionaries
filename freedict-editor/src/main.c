/** @file
 * @brief Contains the main() function
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gnome.h>
#include <glade/glade.h>

#include "callbacks.h"

GladeXML *my_glade_xml;
GtkWidget* app1;

int
main (int argc, char *argv[])
{
  // g_thread_supported() should be renamed to g_thread_initialized()
  if(!g_thread_supported()) g_thread_init(NULL);

  // these functions are provided by libbonobo
  bindtextdomain(GETTEXT_PACKAGE, PACKAGE_LOCALE_DIR);
  bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
  textdomain(GETTEXT_PACKAGE);

  GnomeProgram *app = gnome_program_init (PACKAGE, VERSION, LIBGNOMEUI_MODULE,
      argc, argv,
      GNOME_PARAM_APP_DATADIR, PACKAGE_DATA_DIR,
      LIBGNOMEUI_PARAM_DEFAULT_ICON,
      PACKAGE_DATA_DIR "/" PACKAGE "/freedict.png",
      NULL);

  // set selected_filename with name of file to open on start
  poptContext con;
  g_object_get(G_OBJECT(app), GNOME_PARAM_POPT_CONTEXT, &con, NULL);
  extern char *selected_filename;
  selected_filename = (char *) poptGetArg(con);
  poptFreeContext(con);

  glade_gnome_init();
  if(g_file_test(PACKAGE_DATA_DIR "/" PACKAGE "/freedict-editor.glade", G_FILE_TEST_EXISTS))
    my_glade_xml =
      glade_xml_new(PACKAGE_DATA_DIR "/" PACKAGE "/freedict-editor.glade", NULL, NULL);
  else if(g_file_test("freedict-editor.glade", G_FILE_TEST_EXISTS))
    my_glade_xml = glade_xml_new("freedict-editor.glade", NULL, NULL);
  else if(g_file_test("../freedict-editor.glade", G_FILE_TEST_EXISTS))
    my_glade_xml = glade_xml_new("../freedict-editor.glade", NULL, NULL);
  if(!my_glade_xml)
  {
    fprintf(stderr, _("Failed to load glade interface description.  "
	  "I tried '%s', '%s' and '%s'.\n"),
	PACKAGE_DATA_DIR "/" PACKAGE "/freedict-editor.glade",
	"freedict-editor.glade",
	"../freedict-editor.glade");
    return 1;
  }

  glade_xml_signal_autoconnect(my_glade_xml);

  app1 = glade_xml_get_widget(my_glade_xml, "app1");
  gtk_widget_show_all(app1);
  on_app1_show(NULL, NULL);// XXX this event handler is not called by show_all?

  extern void myload(const char *filename);
  if(selected_filename) myload(selected_filename);

  gtk_main();

  return 0;
}
