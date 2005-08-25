#include <gnome.h>

#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxslt/xslt.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>


void
on_new1_activate                       (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_open1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_save1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_save_as1_activate                   (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_quit1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_cut1_activate                       (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_copy1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_paste1_activate                     (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_clear1_activate                     (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_properties1_activate                (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_preferences1_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_about1_activate                     (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_openbutton_clicked                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_fileselection1_close                (GtkDialog       *dialog,
                                        gpointer         user_data);

void
on_quit1_activate                      (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_ok_button1_clicked                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_app1_hide                           (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_cancel_button1_clicked              (GtkButton       *button,
                                        gpointer         user_data);

void
on_select_entry_changed                (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_treeview1_row_activated             (GtkTreeView     *treeview,
                                        GtkTreePath     *path,
                                        GtkTreeViewColumn *column,
                                        gpointer         user_data);

void
on_app1_hide                           (GtkWidget       *widget,
                                        gpointer         user_data);

gboolean
on_textview1_focus_out_event           (GtkWidget       *widget,
                                        GdkEventFocus   *event,
                                        gpointer         user_data);

gboolean
on_app1_window_state_event             (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data);

gboolean
on_app1_delete_event                   (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data);

void
on_save_button_clicked                 (GtkButton       *button,
                                        gpointer         user_data);

void
on_new_entry_button_clicked            (GtkButton       *button,
                                        gpointer         user_data);

void
on_delete_button_clicked               (GtkButton       *button,
                                        gpointer         user_data);

void
on_app1_show                           (GtkWidget       *widget,
                                        gpointer         user_data);

gboolean
on_notebook1_select_page               (GtkNotebook     *notebook,
                                        gboolean         move_focus,
                                        gpointer         user_data);

void
on_notebook1_switch_page               (GtkNotebook     *notebook,
                                        GtkNotebookPage *page,
                                        guint            page_num,
                                        gpointer         user_data);

void
on_notebook1_change_current_page       (GtkNotebook     *notebook,
                                        gint             offset,
                                        gpointer         user_data);

gboolean
on_notebook1_focus_tab                 (GtkNotebook     *notebook,
                                        GtkNotebookTab   type,
                                        gpointer         user_data);

gboolean
on_vbox4_focus_out_event               (GtkWidget       *widget,
                                        GdkEventFocus   *event,
                                        gpointer         user_data);

void
on_sense1_optionmenu_changed           (GtkOptionMenu   *optionmenu,
                                        gpointer         user_data);

void
on_slang1_activate                     (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_formal1_activate                    (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_official1_activate                  (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_botanics1_activate                  (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_science1_activate                   (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_add_sense_button_clicked            (GtkButton       *button,
                                        gpointer         user_data);

void
on_remove_sense_button_clicked         (GtkButton       *button,
                                        gpointer         user_data);

void
on_sense1_tr_add_button_clicked        (GtkButton       *button,
                                        gpointer         user_data);

void
on_sense1_tr_delete_button_clicked        (GtkButton       *button,
                                        gpointer         user_data);


void
on_sense1_xr1_combo_entry_changed      (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_apply_button_clicked                (GtkButton       *button,
                                        gpointer         user_data);

void
on_form_entry_changed                  (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_form_optionmenu_changed             (GtkOptionMenu   *optionmenu,
                                        gpointer         user_data);

void
on_form_entry_changed                  (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_form_optionmenu_changed             (GtkOptionMenu   *optionmenu,
                                        gpointer         user_data);

void
on_cancel_edit_button_clicked          (GtkButton       *button,
                                        gpointer         user_data);

gboolean
on_treeview1_select_cursor_row         (GtkTreeView     *treeview,
                                        gboolean         start_editing,
                                        gpointer         user_data);

void
on_treeview1_cursor_changed            (GtkTreeView     *treeview,
                                        gpointer         user_data);

gboolean
on_treeview1_move_cursor               (GtkTreeView     *treeview,
                                        GtkMovementStep  step,
                                        gint             count,
                                        gpointer         user_data);

gboolean
on_treeview1_toggle_cursor_row         (GtkTreeView     *treeview,
                                        gpointer         user_data);

void
on_treeview1_set_focus_child           (GtkContainer    *container,
                                        GtkWidget       *widget,
                                        gpointer         user_data);

void
on_select_entry_changed                (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_bonobo_experiment1_activate         (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_app1_drag_data_received             (GtkWidget       *widget,
                                        GdkDragContext  *drag_context,
                                        gint             x,
                                        gint             y,
                                        GtkSelectionData *data,
                                        guint            info,
                                        guint            time,
                                        gpointer         user_data);

gboolean
on_entry2_focus_in_event               (GtkWidget       *widget,
                                        GdkEventFocus   *event,
                                        gpointer         user_data);

gboolean
on_entry2_focus_out_event              (GtkWidget       *widget,
                                        GdkEventFocus   *event,
                                        gpointer         user_data);

void
on_spell_check1_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_spell_replace_button_clicked        (GtkButton       *button,
                                        gpointer         user_data);

void
on_spell_replace_all_button_clicked    (GtkButton       *button,
                                        gpointer         user_data);

void
on_spell_ignore_button_clicked         (GtkButton       *button,
                                        gpointer         user_data);

void
on_spell_ignore_all_button_clicked     (GtkButton       *button,
                                        gpointer         user_data);

void
on_spell_add_button_clicked            (GtkButton       *button,
                                        gpointer         user_data);

void
on_spell_close_button_clicked          (GtkButton       *button,
                                        gpointer         user_data);

void
on_check_dict_combo_entry_changed      (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_spell_headwords_radiobutton_toggled (GtkToggleButton *togglebutton,
                                        gpointer         user_data);

void
on_spell_translations_radiobutton_toggled
                                        (GtkToggleButton *togglebutton,
                                        gpointer         user_data);

void
on_suggestions_treeview_row_activated  (GtkTreeView     *treeview,
                                        GtkTreePath     *path,
                                        GtkTreeViewColumn *column,
                                        gpointer         user_data);

void
on_suggestions_treeview_cursor_changed (GtkTreeView     *treeview,
                                        gpointer         user_data);

void
on_new_file_button_clicked             (GtkButton       *button,
                                        gpointer         user_data);

void
on_view_labels_activate                (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_view_toolbar_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_view_html_activate                  (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_propertybox1_apply                  (GnomePropertyBox *propertybox,
                                        gint             page_num,
                                        gpointer         user_data);

void
on_propertybox1_help                   (GnomePropertyBox *propertybox,
                                        gint             page_num,
                                        gpointer         user_data);

void
on_lock_dockitems1_activate            (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

gboolean
on_propertybox1_close                  (GnomeDialog     *gnomedialog,
                                        gpointer         user_data);

void
on_edit_header_activate                (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_sanity_check_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_view_keyboard_layout_activate       (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_sanity_treeview_row_activated       (GtkTreeView     *treeview,
                                        GtkTreePath     *path,
                                        GtkTreeViewColumn *column,
                                        gpointer         user_data);

void
on_sanity_treeview_cursor_changed      (GtkTreeView     *treeview,
                                        gpointer         user_data);

gboolean
on_sanity_treeview_expand_collapse_cursor_row
                                        (GtkTreeView     *treeview,
                                        gboolean         logical,
                                        gboolean         expand,
                                        gboolean         open_all,
                                        gpointer         user_data);

void
on_sanity_treeview_show                (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_sanity_window_show                  (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_sanity_treeview_row_expanded        (GtkTreeView     *treeview,
                                        GtkTreeIter     *iter,
                                        GtkTreePath     *path,
                                        gpointer         user_data);

void
on_stylesheet_fileentry_changed        (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_editer_entry_changed                (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_source_reference_entry_changed      (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_entry_template_fileentry_changed    (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_gtkeditable_changed                 (GtkEditable     *editable,
                                        gpointer         user_data);

void
on_propertybox1_show                   (GtkWidget       *widget,
                                        gpointer         user_data);

void
on_add_new_entry1_activate             (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_delete_entry1_activate              (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_save_entry1_activate                (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_cancel_edit1_activate               (GtkMenuItem     *menuitem,
                                        gpointer         user_data);

void
on_stop_find_nodeset_clicked           (GtkButton       *button,
                                        gpointer         user_data);

void
on_accept_runtogether_checkbutton_toggled
                                        (GtkToggleButton *togglebutton,
                                        gpointer         user_data);
