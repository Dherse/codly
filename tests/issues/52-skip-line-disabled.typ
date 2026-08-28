#import "../../codly.typ" as codly

#set page(width: 300pt, height: auto)
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
