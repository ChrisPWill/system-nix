import { Astal } from "ags/gtk4"

import Clock from "./Clock";

export default function Bar() {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

      return <window class="bar" visible anchor={TOP | LEFT | RIGHT}>
        <centerbox>
          <box class="widget" $type="center">
            <Clock />
          </box>
        </centerbox>
      </window>;
}
