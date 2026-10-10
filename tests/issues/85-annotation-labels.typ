#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)
#show: codly.ref-set_(by: "item")

@test1

#figure(caption: "Test")[
  #codly.new(
    block-label: <figure>,
    annotations: (
      (start: 2, label: <test1>),
    ),
    ```py
      print("Hello, world!")

      for i in range(1, 5):
          print(i)

      if i == 3:
          print("Three!")
    ```,
  )
] <figure>

@test2
@test3

#figure(caption: "Test")[
  #codly.new(
    block-label: <figure2>,
    annotations: (
      (start: 2, label: <test2>),
      (start: 4, label: <test3>),
    ),
    ```py
      print("Hello, world!")

      for i in range(1, 5):
          print(i)

      if i == 3:
          print("Three!")
    ```,
  )
] <figure2>
