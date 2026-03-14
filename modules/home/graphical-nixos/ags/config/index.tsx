import app from "ags/gtk4/app"
import { Astal } from "ags/gtk4"
import { createPoll } from "ags/time"
import { monitorFile } from "ags/file";

app.start({
  main() {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
    const clock = createPoll("", 1000, "date")

    return (
      <window class="bar" visible anchor={TOP | LEFT | RIGHT}>
        <label label={clock} />
      </window>
    )
  },
})

app.apply_css("./styling/main.css")

monitorFile("./styling", () => {
  app.reset_css();
  app.apply_css("./styling/main.css")
})
