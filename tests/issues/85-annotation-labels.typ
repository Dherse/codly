#import "../../codly.typ": *


#show: codly-init

@test1

#figure(caption: "Test")[
  #codly(
    reference-by: "item",
    annotations: (
      (start: 2, label: <test1>),
    )
  )
  ```py
  print("Hello, world!")

  for i in range(1, 5):
      print(i)

  if i == 3:
      print("Three!")
  ```
] <figure>

@test2
@test3

#figure(caption: "Test")[
  #codly(
    reference-by: "item",
    annotations: (
      (start: 2, label: <test2>),
      (start: 4, label: <test3>),
    )
  )
  ```py
  print("Hello, world!")

  for i in range(1, 5):
      print(i)

  if i == 3:
      print("Three!")
  ```
] <figure2>