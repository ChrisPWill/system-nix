import { Astal } from "ags/gtk4";

import Clock from "./Clock";
import Network from "./Network";

export default function Bar() {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window class="bar" visible anchor={TOP | LEFT | RIGHT}>
      <centerbox>
        <box $type="center">
          <box class="widget button">
            <Clock />
          </box>
        </box>
        <box $type="end">
          <box class="widget">
            <Network />
          </box>
        </box>
      </centerbox>
    </window>
  );
}
