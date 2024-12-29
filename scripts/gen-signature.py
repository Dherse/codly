import json

f = open("src/args.json", encoding="utf-8")
args = json.load(f)

with open("codly.typ", "w", encoding="utf-8") as out:
    out.write("#import \"src/lib.typ\": (\n  codly-init,\n  codly-reset,\n  no-codly,\n  codly-enable,\n  codly-disable,\n  codly-range,\n  codly-offset,\n  codly-skip,\n  typst-icon,\n)\n\n")
    out.write("#let __codly-default = context [ Codly Default ]\n\n")

    out.write("/// See the full documentation: https://raw.githubusercontent.com/Dherse/codly/main/docs.pdf\n")
    out.write("/// \n")
    for name, arg in args.items():
        ty = ", ".join(arg["ty"]).replace("type(none)", "none").replace("type(auto)", "auto")
        if arg["function"]:
            ty += ", function"
        out.write(f"/// - {name} ({ty}): {name}\n")

    out.write("/// -> content\n")
    out.write("#let codly(\n")
    for name in args:
        out.write(f"  {name}: __codly-default,\n")
    out.write(") = {\n  import \"src/lib.typ\": __codly-inner\n")
    out.write("  let out = (:)\n")
    for name in args:
        out.write(f"  if {name} != __codly-default {{\n    out.insert(\"{name}\", {name})\n  }}\n")
    out.write("\n  __codly-inner(..out)\n")
    out.write("}\n\n")

    out.write("""/// Allows setting codly setting locally.
/// Anything that happens inside the block will have the settings applied only to it.
/// The pre-existing settings will be restored after the block. This is useful
/// if you want to apply settings to a specific block only.
///
/// *Special:*
/// #local(default-color: red)[
///   ```
///   Hello, world!
///   ```
/// ]
///
/// *Normal:*
/// ```
/// Hello, world!
/// ```
///
""")
    out.write("/// See the full documentation: https://raw.githubusercontent.com/Dherse/codly/main/docs.pdf\n")
    out.write("/// \n")

    out.write("/// - body (content): the content to be locally styled\n")
    out.write("/// - nested (bool): whether to enable nested local states\n")
    for name, arg in args.items():
        ty = ", ".join(arg["ty"]).replace("type(none)", "none").replace("type(auto)", "auto")
        if arg["function"]:
            ty += ", function"
        out.write(f"/// - {name} ({ty}): {name}\n")

    out.write("/// -> content\n")
    out.write("#let local(\n")
    out.write("  body,\n")
    out.write("  nested: false,\n")
    for name in args:
        out.write(f"  {name}: __codly-default,\n")
    out.write(") = {\n  import \"src/lib.typ\": __local-inner\n")
    out.write("  let out = (:)\n")
    for name in args:
        out.write(f"  if {name} != __codly-default {{\n    out.insert(\"{name}\", {name})\n  }}\n")
    out.write("\n  __local-inner(body, nested: nested, ..out)\n")
    out.write("}\n")
    out.close()