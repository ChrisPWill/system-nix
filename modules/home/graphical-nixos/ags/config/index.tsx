import app from "ags/gtk4/app"

import scss from "./styling/main.scss";

import Bar from "./bar";

app.start({
  main() {
    return (
      <Bar />
    )
  },

  css: scss,
})

