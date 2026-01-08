//
// Created by Orzklv on 8/01/26.
//

#include "app.h"

//
// Should print some hello world
//
void print_hello(GtkWidget *widget, gpointer data)
{
  g_print("Hello World\n");
}

//
// Should provide the active view for a GTK application
//
void activate(GtkApplication *app, gpointer user_data)
{
  GtkWidget *window;
  GtkWidget *button;
  GtkWidget *box;

  window = gtk_application_window_new(app);
  gtk_window_set_title(GTK_WINDOW(window), "Window");
  gtk_window_set_default_size(GTK_WINDOW(window), 200, 200);

  box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
  gtk_widget_set_halign(box, GTK_ALIGN_CENTER);
  gtk_widget_set_valign(box, GTK_ALIGN_CENTER);

  gtk_window_set_child(GTK_WINDOW(window), box);

  button = gtk_button_new_with_label("Hello World");

  g_signal_connect(button, "clicked", G_CALLBACK(print_hello), NULL);
  g_signal_connect_swapped(button, "clicked", G_CALLBACK(gtk_window_destroy),
                           window);

  gtk_box_append(GTK_BOX(box), button);

  gtk_window_present(GTK_WINDOW(window));
} // end of function activate
