#include <gnome.h>

// a type for option menu contents
typedef struct _Values Values;

struct _Values
{
  char *label;
  char *value;
};

// export these variables, so they can be used in callbacks.c
extern const Values pos_values_default[],
       num_values_default[],
       domain_values_default[],
       xr_values_default[],
       gen_values_default[];
extern Values *pos_values,
       *num_values,
       *domain_values,
       *xr_values,
       *gen_values;

void my_g_slist_free_all(GSList *g);
GSList *Values2GSList(const Values *values);
Values *GSList2Values(GSList *g);
void my_free_values_array(Values **v);
const gchar *index2value(const Values *values, const int index);
int value2index(const Values *values, const gchar *value);
