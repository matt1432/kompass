public class Kompass.Tray : Gtk.Box {

    public AstalTray.Tray tray { get; private set; }
    private HashTable<string, Gtk.Widget> items;

    construct {
        this.items = new HashTable<string, Gtk.Widget>(str_hash, str_equal);
        this.tray = AstalTray.get_default();
        this.tray.item_added.connect((obj, item_id) => {
          if(this.items.contains(item_id)) return;
          var item = create_tray_item(tray.get_item(item_id));
          this.items.insert(item_id, item);
          this.append(item);
        });
        this.tray.item_removed.connect((obj, item_id) => {
          if(!this.items.contains(item_id)) return;
          var item = this.items.take(item_id);
          this.remove(item);
        });
    }

    private Gtk.Widget create_tray_item(AstalTray.TrayItem item) {
      
        var button = new Gtk.MenuButton();
        button.direction = Gtk.ArrowType.RIGHT;
        button.add_css_class("tray-item");
  
        item.notify["action_group"].connect(() => {
          button.insert_action_group("dbusmenu", item.action_group);
        });
        button.insert_action_group("dbusmenu", item.action_group);
        item.bind_property("menu-model", button, "menu-model", BindingFlags.SYNC_CREATE);
        var icon = new Gtk.Image();
        item.bind_property("gicon", icon, "gicon", BindingFlags.SYNC_CREATE);
        button.set_child(icon);
        return button;
    }
}
