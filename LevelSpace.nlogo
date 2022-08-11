extensions [ ls ]

globals[ random-model front-to-back-model back-to-front-model window-to-aisle-model
  random-ticks random-total-wait-time random-average-wait-time random-revenue
  front-to-back-ticks front-to-back-total-wait-time front-to-back-average-wait-time front-to-back-revenue
  back-to-front-ticks back-to-front-total-wait-time back-to-front-average-wait-time back-to-front-revenue
  window-to-aisle-ticks window-to-aisle-total-wait-time window-to-aisle-average-wait-time window-to-aisle-revenue
  show-model-previous]

to setup
  ls:reset ; reset LevelSpace
  clear-all
  if number-of-passenger > (number-of-row * number-of-seat-per-row)
  [set number-of-passenger number-of-row * number-of-seat-per-row]
  ls:create-models 1 "Airplane Boarding.nlogo" ;; Model for random boarding
  set random-model last ls:models
  ls:create-models 1 "Airplane Boarding.nlogo" ;; Model for front-to-back boarding
  set front-to-back-model last ls:models
  ls:create-models 1 "Airplane Boarding.nlogo" ;; Model for back-to-front-model boarding
  set back-to-front-model last ls:models
  ls:create-models 1 "Airplane Boarding.nlogo" ;; Model for window-to-aisle-model boarding
  set window-to-aisle-model last ls:models

  ls:ask random-model [ set boarding-strategies "random"] ;; Set boarding type for model
  ls:ask front-to-back-model [ set boarding-strategies "front-to-back"]
  ls:ask back-to-front-model [ set boarding-strategies "back-to-front"]
  ls:ask window-to-aisle-model [ set boarding-strategies "window-to-aisle"]

  if show-model = true[ ;; show or hide model
    ls:show random-model
    ls:show front-to-back-model
    ls:show back-to-front-model
    ls:show window-to-aisle-model
  ]

  ls:let new-row number-of-row ;; update new setting to model
  ls:let new-column number-of-seat-per-row
  ls:let new-passenger number-of-passenger
  ls:let new-group-size boarding-group-size
  ls:ask ls:models [
    set number-of-row new-row
    set number-of-seat-per-row new-column
    set number-of-passenger new-passenger
    set boarding-group-size new-group-size
    setup
  ]
  reset-ticks
end

to go
  let running-model ls:models ls:with [ time-to-stop? = false ] ;; get the list of model that is running
  if running-model = [][ stop ] ;; if no model running, stop.
  ls:ask ls:models [ go ];; finally ask all models to go

  let ended-model ls:models ls:with [ time-to-stop? = true ] ;; get the list of model that is ended

  if ended-model != [][
    let model-id first ended-model ;; get the first model id in list
    if model-id = 0 [ handle-random-end ]
    if model-id = 1 [ handle-front-to-back-end ]
    if model-id = 2 [ handle-back-to-front-end  ]
    if model-id = 3 [ handle-window-to-aisle-end ]
    ls:close model-id ;; kill the ended model
  ]
  tick
end

to handle-random-end ;; get ending variable for random
  set random-ticks [ticks] ls:of 0
  set random-total-wait-time [total-wait-time] ls:of 0
  set random-average-wait-time [average-wait-time] ls:of 0
  set random-revenue [revenue] ls:of 0
end

to handle-front-to-back-end ;; get ending variable for front-to-back
  set front-to-back-ticks [ticks] ls:of 1
  set front-to-back-total-wait-time [total-wait-time] ls:of 1
  set front-to-back-average-wait-time [average-wait-time] ls:of 1
  set front-to-back-revenue [revenue] ls:of 1
end

to handle-back-to-front-end ;; get ending variable for back-to-front
  set back-to-front-ticks [ticks] ls:of 2
  set back-to-front-total-wait-time [total-wait-time] ls:of 2
  set back-to-front-average-wait-time [average-wait-time] ls:of 2
  set back-to-front-revenue [revenue] ls:of 2
end

to handle-window-to-aisle-end ;; get ending variable for window-to-aisle
  set window-to-aisle-ticks [ticks] ls:of 3
  set window-to-aisle-total-wait-time [total-wait-time] ls:of 3
  set window-to-aisle-average-wait-time [average-wait-time] ls:of 3
  set window-to-aisle-revenue [revenue] ls:of 3
end
@#$#@#$#@
GRAPHICS-WINDOW
20
30
199
210
-1
-1
13.2
1
10
1
1
1
0
1
1
1
-6
6
-6
6
1
1
1
ticks
30.0

BUTTON
20
120
200
225
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
20
15
200
120
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
20
235
200
268
show-model
show-model
1
1
-1000

SLIDER
235
20
430
53
number-of-row
number-of-row
3
100
36.0
1
1
row
HORIZONTAL

SLIDER
235
60
430
93
number-of-seat-per-row
number-of-seat-per-row
2
10
6.0
2
1
seat
HORIZONTAL

MONITOR
230
180
430
225
size of plane
number-of-row * number-of-seat-per-row
17
1
11

PLOT
470
10
800
285
Seated Passenger
Ticks
#passenger
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"random" 1.0 0 -1184463 true "" "plot [ seated ] ls:of random-model"
"front-to-back" 1.0 0 -2674135 true "" "plot [seated] ls:of front-to-back-model"
"back-to-front" 1.0 0 -13345367 true "" "plot [ seated ] ls:of back-to-front-model"
"window-to-aisle" 1.0 0 -13840069 true "" "plot [ seated ] ls:of window-to-aisle-model"

SLIDER
235
100
430
133
number-of-passenger
number-of-passenger
5
number-of-row * number-of-seat-per-row
216.0
1
1
NIL
HORIZONTAL

SLIDER
235
140
430
173
boarding-group-size
boarding-group-size
0
50
15.0
1
1
%
HORIZONTAL

PLOT
810
10
1125
285
Enroute Passenger
Ticks
#passenger
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"random" 1.0 0 -1184463 true "" "plot [ enroute ] ls:of random-model"
"front-to-back" 1.0 0 -2674135 true "" "plot [enroute] ls:of front-to-back-model"
"back-to-front" 1.0 0 -13345367 true "" "plot [enroute] ls:of back-to-front-model"
"window-to-aisle" 1.0 0 -13840069 true "" "plot [enroute] ls:of window-to-aisle-model"

PLOT
470
295
795
555
Not Board Passenger
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Random" 1.0 0 -1184463 true "" "plot [ not-board ] ls:of random-model"
"front-to-back" 1.0 0 -2674135 true "" "plot [ not-board ] ls:of front-to-back-model"
"back-to-front" 1.0 0 -13345367 true "" "plot [ not-board ] ls:of back-to-front-model"
"window-to-aisle" 1.0 0 -13840069 true "" "plot [ not-board ] ls:of window-to-aisle-model"

PLOT
810
295
1125
555
Average Wait Time
ticks
ticks/passenger
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"random" 1.0 0 -1184463 true "" "plot [ average-wait-time ] ls:of random-model"
"front-to-back" 1.0 0 -2674135 true "" "plot [ average-wait-time ] ls:of front-to-back-model"
"back-to-front" 1.0 0 -13345367 true "" "plot [ average-wait-time ] ls:of back-to-front-model"
"window-to-aisle" 1.0 0 -13840069 true "" "plot [ average-wait-time ] ls:of window-to-aisle-model"

TEXTBOX
45
310
115
341
Random
10
0.0
1

MONITOR
20
335
120
380
ending ticks
random-ticks
3
1
11

TEXTBOX
180
280
310
300
Ending Variable
16
0.0
1

MONITOR
20
385
120
430
total wait time
random-total-wait-time
3
1
11

MONITOR
20
435
120
480
average wait time
random-average-wait-time
3
1
11

MONITOR
20
485
120
530
revenue
random-revenue
3
1
11

TEXTBOX
145
310
230
328
front-to-back
10
0.0
1

MONITOR
130
335
230
380
ending ticks
front-to-back-ticks
3
1
11

MONITOR
130
385
230
430
total wait time
front-to-back-total-wait-time
3
1
11

MONITOR
130
435
230
480
average wait time
front-to-back-average-wait-time
3
1
11

MONITOR
130
485
230
530
revenue
front-to-back-revenue
3
1
11

TEXTBOX
250
310
335
328
back-to-front
10
0.0
1

MONITOR
240
335
340
380
ending ticks
back-to-front-ticks
3
1
11

MONITOR
240
385
340
430
total wait time
back-to-front-total-wait-time
3
1
11

MONITOR
240
435
340
480
average wait time
back-to-front-average-wait-time
3
1
11

MONITOR
240
485
340
530
revenue
back-to-front-revenue
3
1
11

TEXTBOX
360
310
455
328
window-to-aisle
10
0.0
1

MONITOR
350
335
450
380
ending ticks
window-to-aisle-ticks
3
1
11

MONITOR
350
385
450
430
total wait time
window-to-aisle-total-wait-time
3
1
11

MONITOR
350
435
450
480
average wait time
window-to-aisle-average-wait-time
3
1
11

MONITOR
350
485
450
530
revenue
window-to-aisle-revenue
3
1
11

@#$#@#$#@
## WHAT IS IT?

This model uses LevelSpace to launch 4 models to run the Airplane Boarding Model with four different boarding strategies: _random_, _front to end_, _end to front_, and _windows to aisle_.

Users will be able to observe and discover what boarding type is best suited for different plane sizes easier. 

## HOW IT WORKS

The model will create 4 models to run four different types of boarding strategies. When All passengers are boarded, the result will show on the monitor at the _Ending Variable_ section. The plot also shows the status of all four different models with different boarding strategies.

## HOW TO USE IT

Click _SETUP_ to create all four models, and _GO_ to run the models.

1. Set the number of row of the airplane (Min 3, Max 100).
2. Set the number of seat per row of the airplane (Min 2, Max 10).
3. Set the number of passengers on this airplane.
4. Set the boarding group size. This is used when you are using _front-to-back_ or _back-to-front_ method. Passenger will not board until the previous group is done boarding. 

## THINGS TO NOTICE

When changing the size of the plane, remember also to change the number of passengers to make sure the plane is able to fit that many passengers.

## THINGS TO TRY

Run the model on several different plane size. Is it always true that one is the best? Worst?

Run the model with different boarding group sizes and different numbers of different rows. Is the result changing?

## EXTENDING THE MODEL

Is it possible to allow airlines to compete with each other?

 * Each airline will have a satisfaction rate that will affect the number of passengers on the next flight. 
 * Two airlines will also be competing with each other which changes the number of passengers on the next flight. 

## NETLOGO FEATURES

This model uses LevelSpace to run all four different types of boarding strategies simultaneously. Which user can better observe the result of the model.

## CREDITS AND REFERENCES

Wilensky, U. (2016). Model Interactions Example. https://ccl.northwestern.edu/netlogo/models/ModelInteractionsExample. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
need-to-manually-make-preview-for-this-model
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="same size plane different model" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>number-of-passenger</metric>
    <metric>random-ticks</metric>
    <metric>random-total-wait-time</metric>
    <metric>random-average-wait-time</metric>
    <metric>random-revenue</metric>
    <metric>front-to-back-ticks</metric>
    <metric>front-to-back-total-wait-time</metric>
    <metric>front-to-back-average-wait-time</metric>
    <metric>front-to-back-revenue</metric>
    <metric>back-to-front-ticks</metric>
    <metric>back-to-front-total-wait-time</metric>
    <metric>back-to-front-average-wait-time</metric>
    <metric>back-to-front-revenue</metric>
    <metric>window-to-aisle-ticks</metric>
    <metric>window-to-aisle-total-wait-time</metric>
    <metric>window-to-aisle-average-wait-time</metric>
    <metric>window-to-aisle-revenue</metric>
    <enumeratedValueSet variable="number-of-passenger">
      <value value="1000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-of-row" first="5" step="2" last="100"/>
    <enumeratedValueSet variable="boarding-group-size">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-model">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-of-seat-per-row" first="2" step="2" last="10"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
