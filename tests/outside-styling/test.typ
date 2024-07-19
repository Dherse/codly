#set page(height: auto, width: 300pt, margin: 10pt)

*Before Codly:*

#let replace-at(str, colors) = {
  for (i, c) in str.clusters().enumerate() {
    let found = false
    
    for (color, positions) in colors.pairs() {
      if positions.contains(i) {
        text(eval(color).darken(20%), c)
        //highlight(fill: eval(color).lighten(75%), top-edge: "ascender", extent: 0.4pt, c)
        //underline(stroke: 0.7pt + eval(color), extent: 0.4pt, c)
        
        found = true
        break
      }
    }

    if not found {
      c
    }
  }
}

#[
    #show raw.line: it => {
    if it.number == 1 {
      replace-at(it.text, (green: (4,), red: (10,), blue: (16,), purple: (22,)))
    } else if it.number == 2 {
      replace-at(it.text, (green: range(4,5), red: range(10,12), blue: range(17,20), purple: range(25,28)))
    } else if it.number == 3 {
      replace-at(it.text, (green: (0,1,2,3,4,5,6,7,8)))
    } else {
      it
    }
  }
  
  ```
  Test1 test2 test3 test4
  Test1 test22 test333 test444
  Test12345
  ```

  
  ```python
  if test:
    pass
  ```
]

*After Codly:*

#import "../../codly.typ": *
#show: codly-init.with()

#[
  #show raw.line: it => {
    if it.number == 1 {
      replace-at(it.text, (green: (4,), red: (10,), blue: (16,), purple: (22,)))
    } else if it.number == 2 {
      replace-at(it.text, (green: range(4,5), red: range(10,12), blue: range(17,20), purple: range(25,28)))
    } else if it.number == 3 {
      replace-at(it.text, (green: (0,1,2,3,4,5,6,7,8)))
    } else {
      it
    }
  }
  
  ```
  Test1 test2 test3 test4
  Test1 test22 test333 test444
  Test12345
  ```

  
  ```python
  if test:
    pass
  ```
]