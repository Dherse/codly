#set page(width: 520pt, height: auto, margin: 12pt, fill: white)
#show: body => {
  if sys.inputs.at("font", default: "dejavu") == "noto" {
    show raw: set text(font: "Noto Sans Mono")
    body
  } else {
    body
  }
}
