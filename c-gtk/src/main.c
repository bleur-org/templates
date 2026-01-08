#include "app.h"

//
// main is where all program execution starts
//
int main(int argc, char **argv)
{
  GtkApplication *app;
  int status;

  app = gtk_application_new("org.bleur.cgtk", G_APPLICATION_DEFAULT_FLAGS);
  g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
  status = g_application_run(G_APPLICATION(app), argc, argv);
  g_object_unref(app);

  return status;
} // end of function main
