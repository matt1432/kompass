class Kompass.Application : Astal.Application {
  public static Application instance;

  public override void request(string msg, SocketConnection conn) {
    AstalIO.write_sock.begin(conn, @"missing response implementation on $instance_name");
  }

  public override void activate() {
    base.activate();

    if (AstalRiver.get_default() == null) {
      GLib.warning("could not connect to river.\n");
    }

    Gtk.IconTheme icon_theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default());
    icon_theme.add_resource_path("/com/github/kotontrion/kompass/icons/");

    Gtk.CssProvider provider = new Gtk.CssProvider();
    provider.load_from_resource("com/github/kotontrion/kompass/style.css");
    Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), provider,
                                              Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

    var mons = Gdk.Display.get_default().get_monitors();
    for (var i = 0; i <= mons.get_n_items(); ++i) {
      var monitor = (Gdk.Monitor)mons.get_item(i);
      if (monitor != null) {
        var win = new Kompass.Bar(monitor);
        win.present();
      }
    }

    mons.items_changed.connect((p, r, a) => {
      Gdk.Display.get_default().sync();
      for (; a > 0; a--) {
        var monitor = (Gdk.Monitor)mons.get_item(p++);
        var win = new Kompass.Bar(monitor);
        win.present();
      }
    });

    this.hold();
  }

  construct {
    instance_name = "kompass";
    try {
      acquire_socket();
    }
    catch (Error e) {
      printerr("%s", e.message);
    }
    instance = this;
  }
}