import GLib from "gi://GLib"
import Gtk from "gi://Gtk?version=4.0"

import { createPoll } from "ags/time"

export default function Clock({ format = "%H:%M:%S %a %d" }) {
  const time = createPoll("", 1000, () => {
    return GLib.DateTime.new_now_local().format(format)!
  })

  return (
    <menubutton class="flat">
      <label label={time} />
      <popover>
        <Gtk.Calendar />
      </popover>
    </menubutton>
  )
}
