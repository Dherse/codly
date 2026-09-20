#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)

#show raw.where(block: true): codly.new

#lorem(30)

#show raw.where(lang: "foo_lang"): it => [
  #show regex("\b(for|to|begin|end)\b"): keyword => text(weight: "bold", keyword)
  #it
]

#figure(kind: raw, caption: "my_code")[
  ```foo_lang
  for i=1 to 10
  begin
    print(i)
  end
  ```
]<lst1-fig>

In @lst1-fig, #lorem(10).
