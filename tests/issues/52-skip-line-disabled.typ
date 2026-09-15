#import "../../codly.typ" as codly

#set page(width: 240pt, height: auto, margin: 5pt)
#codly.new(number-enabled: false, skips: ((2, 4),), ```txt
a
b
c
d
e
f
g
```)

#codly.new(skips: ((2, 4),), ```txt
a
b
c
d
e
f
g
```)
