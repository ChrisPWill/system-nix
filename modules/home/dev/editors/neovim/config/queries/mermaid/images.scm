; snacks.image only ships queries for mermaid fenced inside markdown and other
; doc formats. A standalone .mmd file is a single diagram, so treat the whole
; file as one image.
;
; The mermaid grammar rejects valid diagrams it doesn't understand (e.g.
; flowcharts with HTML labels), leaving an ERROR root instead of source_file.
; mmdc renders those fine, so match the root whatever the parse produced.
; is-root? (utils/treesitter/predicates.lua) skips the ERROR nodes the grammar
; nests even inside valid trees, which would render as broken fragments.
([(source_file) (ERROR)] @image @image.content
  (#is-root? @image)
  (#set! image.ext "chart.mmd"))
