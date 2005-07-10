#include <gnome.h>
#include <libxml/parser.h>


typedef struct _Sense_trans Sense_trans;
typedef struct _Sense_xr Sense_xr;
typedef struct _Sense Sense;

struct _Sense_trans
{
  // GtkWidgets of this translation equivalent
  GtkWidget *hbox, *entry, *pos_optionmenu, *gen_optionmenu;

  // XXX needed only during entry parsing -> put into its own struct?
  // xmlNodes of this translation equivalent
  xmlNodePtr xTr, xPos, xGen;
};

struct _Sense_xr
{
  GtkWidget *type_optionmenu, *combo, *combo_entry;

  xmlNodePtr xRef, xType;
};

struct _Sense
{
  int nr;// zero based
  GtkWidget *frame, *table, *label,

    *domain_label, *domain_optionmenu,

    *tr_label, *tr_vbox,
    *tr_hbuttonbox, *tr_add_button, *tr_add_alignment, *tr_add_hbox,
    *tr_add_image, *tr_add_label, *tr_delete_button, *tr_delete_alignment,
    *tr_delete_hbox, *tr_delete_image, *tr_delete_label,

    *def_label, *note_label, *note_entry, *def_entry,
    *example_label, *example_entry, *example_tr_entry,

    *xr_label, *xr_table,
    *xr_hbuttonbox, *xr_add_button, *xr_add_alignment, *xr_add_hbox,
    *xr_add_image, *xr_add_label, *xr_delete_button, *xr_delete_alignment,
    *xr_hbox, *xr_delete_image, *xr_delete_label;

  GArray *trans, *xr;

  xmlNodePtr xSense, xDef, xNote, xUsg, xEx, xExTr;
};

// a type for option menu contents
typedef struct _Values Values;

struct _Values
{
  char *label;
  char *value;
};


// global variables

// senses of the currently edited entry in Form view
extern GArray *senses;
extern gboolean form_modified;

// export these variables, so it can be used in callbacks.c
extern const Values pos_values[], num_values[];

GtkWidget   *create_menu(GtkOptionMenu *parent, const char *accel_path,
		    const Values *v);

// used in callbacks.c
Sense_trans *sense_append_trans(const Sense *s);
Sense       *senses_append(GArray *senses);
void         senses_remove_last(GArray *senses);

// used in callbacks.c
gboolean     xml2form(const xmlNodePtr entry, GArray *senses);
xmlNodePtr   form2xml(const GArray *senses);
