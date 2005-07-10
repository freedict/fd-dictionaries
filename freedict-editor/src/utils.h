#include "callbacks.h"

// global variables
extern GtkWidget* app1;
extern xmlDocPtr teidoc, entry_template_doc;
extern xmlNodePtr edited_node;
extern const gchar *selected_filename;
extern int save_as_mode;
extern gboolean file_modified;

// GUI utility functions
void mystatus(const char *format, ...);
void show_in_textview1(const xmlNodePtr n);
void set_edited_node(const xmlNodePtr n);
void setTeidoc(const xmlDocPtr t);
void on_file_modified_changed();
void mysave(void);
