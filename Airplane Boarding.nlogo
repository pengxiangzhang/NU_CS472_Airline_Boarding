breed [passengers passenger]
passengers-own [seat-number status order passenger-type bag bag-end-tick seat-end-tick] ;; seat number is a list, first item is row, second item is column
globals [assistance military loyalty paid group regular current-group total-wait-time]

to setup
  clear-all
  setup-plane
  if number-of-passenger > (number-of-row * number-of-seat-per-row)
  [set number-of-passenger (number-of-row * number-of-seat-per-row)]
  set military ceiling (number-of-passenger * percentage-of-priority-military / 100) ;; calculate numbers of special passenger
  set assistance ceiling (number-of-passenger * percentage-of-priority-assistance / 100)
  set loyalty ceiling (number-of-passenger * percentage-of-priority-loyalty / 100)
  set paid ceiling (number-of-passenger * percentage-of-priority-paid / 100)
  set regular number-of-passenger - military - assistance - loyalty - paid
  set-board-type
  setup-passenger
  reset-ticks
end

to setup-plane
  ask patches with [pycor = 0 and pxcor = 0 ] [set pcolor blue] ;; Set the gate to be blue
  ask patches with [pycor = 0 and (pxcor < number-of-row * 2 + 2 and pxcor > 2)] [set pcolor white] ;; set aisle to be white
  let start-patch 3 ;; Plane start at patch 3
  repeat number-of-row [
    let top-seat 2 ;;Seat start 2 patch above aisle
    let bottom-seat -2 ;;Seat start 2 patch below aisle
    repeat number-of-seat-per-row / 2 [ ;; generate row on each side
      ask patches with [pycor = top-seat  and pxcor = start-patch ] [set pcolor yellow]
      ask patches with [pycor = bottom-seat  and pxcor = start-patch ] [set pcolor yellow]
      set top-seat top-seat + 2
      set bottom-seat bottom-seat - 2
    ]
    set start-patch start-patch + 2
  ]
end

to set-board-type
  if boarding-strategies = "random"[
    ;; Nothing special need to do here
  ]
  if boarding-strategies = "front-to-back"[ set current-group 0 ]
  if boarding-strategies = "back-to-front"[ set current-group 1 ]
  if boarding-strategies = "window-to-aisle"[ set current-group number-of-seat-per-row ] ;; Find the window row
end

to setup-passenger
  create-passengers assistance [
    set shape "person needassistant"
    set color sky
    setxy 0 0
    set size 2
    set passenger-type "assistant"
    set seat-number generate-random-seat-number ;;generate seat number
    set bag random max-luggage-per-passenger ;;generate number of luggage
  ]
  create-passengers military [
    set shape "person soldier"
    set color sky
    setxy 0 0
    set size 2
    set passenger-type "military"
    set seat-number generate-random-seat-number
    set bag random max-luggage-per-passenger
  ]
  create-passengers loyalty [
    set shape "person business"
    set color sky
    setxy 0 0
    set size 2
    set passenger-type "loyalty"
    set seat-number generate-random-seat-number
    set bag random max-luggage-per-passenger
  ]
  create-passengers paid [
    set shape "person graduate"
    set color sky
    setxy 0 0
    set size 2
    set passenger-type "paid"
    set seat-number generate-random-seat-number
    set bag random max-luggage-per-passenger
  ]
  create-passengers regular [
    set shape "person"
    set color sky
    setxy 0 0
    set size 2
    set passenger-type "regular"
    set seat-number generate-random-seat-number
    set bag random max-luggage-per-passenger
  ]
end

to go
  if time-to-stop? ;; check if all passenger is seated
  [stop]
  ask passengers[
    if status = 0 [ move-forward ] ;; Each passenger, if not arrive to seat row then move forward
    if status = 1 [ move-to-seat ] ;; Each passenger, if arrive to seat row then move to seat
  ]
  tick
end

to move-forward
  set heading 90
  let turtle-ahead turtles-on patch-ahead 1 ;; find if any turtle ahead and block the road
  if time-to-start? [
    (ifelse not any? turtle-ahead [ ;; If no one block, move forward
      set heading 90
      fd 0.5]
      pxcor > 2 and status = 0 [ set total-wait-time total-wait-time + 1 ] ;; if someone block, count the time the passenger is waiting
    )
    if ceiling xcor = first seat-number[ ;; When arrive seat
      set status 1
      let wait-time-needed bag * 20 ;; Calculate time needed to put the bag to overhead bin, here assume to be 20 ticks
      set bag-end-tick ticks + wait-time-needed ;; Store the tick that the passenger finish putting their bag
      set total-wait-time total-wait-time + wait-time-needed ;; Count the wait time
    ]
  ]
end

to move-to-seat
  if ticks >= bag-end-tick[ ;; When finish handing the bag
    if ceiling ycor = item 1 seat-number ;; If arrive seat
    [
      set status "seated"
      move-to patch item 0 seat-number item 1 seat-number ;; Replace the turtle just to make it look nicer
      ask patch item 0 seat-number item 1 seat-number [ set pcolor green ]
    ]
    if seat-end-tick = 0[ ;; When first arrive the row
      face patch item 0 seat-number item 1 seat-number ;; Turn to the direction of the seat
      let front-patches patches in-cone abs (item 1 seat-number ) 20 ;; Find turtle that is already seated infront of current turtle's seat
      let turtle-ahead count turtles-on front-patches ;; Count number of turtle blocking the access to the seat
      let wait-time-needed turtle-ahead * 15 ;; Assume need 15 tick to go pass each passenger in front
      set seat-end-tick ticks + wait-time-needed ;; Store the tick that the passenger infront get out and able to get in
      set total-wait-time total-wait-time + wait-time-needed ;; Count the wait time
    ]
    if ticks >= seat-end-tick[ ;; If not arrive seat, move forawd
      fd 0.5]
  ]
end

to-report time-to-stop? ;; check if all paggenger seated
  if all? passengers [ status = "seated" ]
  [ report true ]
  report false
end

to-report time-to-start?
  if who = 0 [ report true ] ;; For the first passenger, always move first to prevent bug of nobody in the agent set
  if xcor > 1 [ report true ] ;; if already board, then always allow to move
  if boarding-strategies = "random"[
    report time-to-setart-random?
  ]
  if boarding-strategies = "front-to-back"[
    report time-to-setart-front?
  ]
  if boarding-strategies = "back-to-front"[
    report time-to-setart-back?
  ]
  if boarding-strategies = "window-to-aisle"[
    report time-to-start-window?
  ]
end

to-report time-to-setart-random?
  report ([xcor] of (turtle (who - 1))) > 1 ;; If board type is random, just boarding using who number
end

to-report time-to-setart-front? ;;front-to-back
  let current-go-group ceiling number-of-row * current-group * 2 + 4 ;; find the row number that should go now(Based on patch, Everyone patch have a seat so times two, Gate to seat has 4 patch)
  if passenger-type != "regular" [ report ([xcor] of (turtle (who - 1))) > 1 ] ;; Special passenger always allow move first
  if not any? turtles with [ xcor < 1 and passenger-type != "regular" ] [ ;; if all special passenger are gone
    if not any? turtles with [ xcor < 1 and item 0 seat-number < current-go-group ] [ set current-group current-group + boarding-group-size / 100 ] ;; if current group are gone, move to next group
    if item 0 seat-number < current-go-group [ report true ] ;; true if the passenger row number is in this group
  ]
  report false
end

to-report time-to-setart-back? ;;back-to-front
  let current-go-group ceiling (number-of-row * current-group * 2 + 4)
  if passenger-type != "regular" [ report ([xcor] of (turtle (who - 1))) > 1 ]
  if not any? turtles with [ xcor < 1 and passenger-type != "regular" ] [
    if not any? turtles with [ xcor < 1 and item 0 seat-number > current-go-group ] [ set current-group current-group - boarding-group-size / 100 ]
    if item 0 seat-number > current-go-group [ report true ]
  ]
  report false
end

to-report time-to-start-window? ;; window-to-aisle
  if passenger-type != "regular" [ report ([xcor] of (turtle (who - 1))) > 1 ]
  if not any? turtles with [ xcor < 1 and passenger-type != "regular" ] [
    if not any? turtles with [ xcor < 1 and (abs item 1 seat-number > current-group) ] [ set current-group current-group - 2 ] ;; If current group are gone
    if abs item 1 seat-number > current-group [ report true ] ;; true if the passenger column is in this group
  ]
  report false
end

to-report generate-random-seat-number
  let cor list 1 1 ;; initial a list
  ask one-of patches with [ pcolor = yellow ][ ;; find a patch that no one assign yet
    set pcolor orange
    set cor list pxcor pycor
  ]
  report cor ;; return the seat number(list)
end

to-report not-board ;; count the total number of passenger not board the plane yet
  report count turtles-on patches with [ pxcor <= 2 ]
end

to-report seated ;; count the total number of passenger already seated
  report count passengers with [ status = "seated" ]
end

to-report enroute ;; count the total number of passenger enroute seated
  report count turtles-on patches with [ pxcor > 2] - seated
end

to-report average-wait-time ;; Average wait jam time for passenger already onboard
  if ticks < 5 [report 0] ;; To prevent on setup, need to devided something by zero.
  report total-wait-time / (enroute + seated)
end

to-report revenue ;; Calculate the revenue
  report priority-boarding-fee * paid + budget-for-ground-operation * number-of-passenger - terminal-use-fee * number-of-passenger - gate-use-fee - landing/takeoff/ATC-fee - ticks * fixed-base-operator
end
@#$#@#$#@
GRAPHICS-WINDOW
22
440
1815
650
-1
-1
7.83
1
10
1
1
1
0
0
0
1
0
204
-11
11
1
1
1
ticks
30.0

SLIDER
18
20
227
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
19
58
228
91
number-of-seat-per-row
number-of-seat-per-row
2
10
6.0
2
1
seat
HORIZONTAL

BUTTON
20
263
234
297
setup
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

MONITOR
21
101
230
146
size of plane
number-of-row * number-of-seat-per-row
17
1
11

SLIDER
285
22
495
55
number-of-passenger
number-of-passenger
5
number-of-row * number-of-seat-per-row
216.0
1
1
people
HORIZONTAL

SLIDER
286
106
498
139
percentage-of-priority-military
percentage-of-priority-military
0
25
1.0
1
1
%
HORIZONTAL

SLIDER
285
63
498
96
percentage-of-priority-assistance
percentage-of-priority-assistance
0
25
1.0
1
1
%
HORIZONTAL

SLIDER
288
151
499
184
percentage-of-priority-loyalty
percentage-of-priority-loyalty
0
25
1.0
1
1
%
HORIZONTAL

SLIDER
288
194
500
227
percentage-of-priority-paid
percentage-of-priority-paid
0
25
2.0
1
1
%
HORIZONTAL

MONITOR
290
319
360
364
Not Board
not-board
3
1
11

MONITOR
431
319
492
364
seated
seated
3
1
11

MONITOR
364
319
424
364
enroute
enroute
3
1
11

BUTTON
21
306
236
340
go
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

SLIDER
524
232
732
265
priority-boarding-fee
priority-boarding-fee
0
100
70.0
5
1
$
HORIZONTAL

SLIDER
524
24
725
57
budget-for-ground-operation
budget-for-ground-operation
0
50
20.0
1
1
$/passenger
HORIZONTAL

SLIDER
522
148
730
181
landing/takeoff/ATC-fee
landing/takeoff/ATC-fee
0
2000
700.0
100
1
$
HORIZONTAL

MONITOR
525
280
594
325
Revnue
revenue
3
1
11

SLIDER
287
235
502
268
max-luggage-per-passenger
max-luggage-per-passenger
0
3
2.0
1
1
luggage
HORIZONTAL

SLIDER
523
190
732
223
fixed-base-operator
fixed-base-operator
0
5
1.2
0.1
1
$/ticks
HORIZONTAL

CHOOSER
20
208
234
253
boarding-strategies
boarding-strategies
"random" "front-to-back" "back-to-front" "window-to-aisle"
0

SLIDER
525
67
726
100
terminal-use-fee
terminal-use-fee
0
20
4.5
0.5
1
$/passenger
HORIZONTAL

SLIDER
522
106
730
139
gate-use-fee
gate-use-fee
0
2000
700.0
100
1
$
HORIZONTAL

PLOT
752
20
1280
223
Seated vs time
ticks
#passenger
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Seated" 1.0 0 -16777216 true "" "plot seated"

PLOT
753
229
1279
434
Enroute vs time
ticks
#passenger
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot enroute"

PLOT
1292
22
1817
223
Not Board vs Time
ticks
#passenger
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot not-board"

SLIDER
289
276
499
309
boarding-group-size
boarding-group-size
0
50
15.0
5
1
%
HORIZONTAL

MONITOR
286
374
374
419
Total Wait Time
total-wait-time
3
1
11

MONITOR
379
375
493
420
Average Wait Time
average-wait-time
3
1
11

PLOT
1292
229
1820
433
Average Wait Time VS time
ticks
ticks/passenger
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-wait-time"

@#$#@#$#@
## WHAT IS IT?

This model is a visualization of the boarding process of the aircraft. There is a number of different methods to board the plane, and different airline like to use a different type of boarding type. Specifically, it aims to model the overall revenue of the airline and the total time it needed to board different sizes of planes and boarding strategies. 

There are numerous possible techniques for boarding an airplane, and there are many elements beyond the boarding strategy, such as the military, passengers who require assistance, loyal passengers, and even passengers who pay are allowed to board before other passengers; the number of seats per row; the plane's fullness; and the number of carry-on bags are all factors to consider.

## HOW IT WORKS

The model will represent an airplane with seats and passengers waiting to board at the gate. Based on their seat and the boarding strategy, each person is placed to a boarding group. When it is their time, the people go towards their seats at each tick. If they want to move to a patch that already has someone in it, they must first wait for that individual to go.

The model is designed to observe:

  * Which boarding strategy  is faster
  * Average Wait time per passenger
  * Revenue of each boarding type with different size of the plane, number of passengers, and boarding strategy. 

## HOW TO USE IT

Click _SETUP_ to set up the models, and _GO_ to run the models.

### Set up the Airplane

1. Set the number of row of the airplane (Min 3, Max 100).
2. Set the number of seat per row of the airplane (Min 2, Max 10).
3. Select the boarding strategy that you would like to use.

### Set up the Passengers

1. Set the number of passengers on this airplane.
2. Set the percentage of passengers who needed assistance amount all passengers, this group will board first.
3. Set the percentage of military type of passenger which will board when passengers needed assistant is all boarded.
4. Set the percentage of loyalty passenger which will board after military passengers.
5. Set the percentage of paid priority boarding passengers, which will board after loyalty passengers. The fee paid will be added to the revenue. 
6. Set the maximum luggage allowed per passenger. Passengers will have a random luggage with the maximum that you set. 
7. Set the boarding group size. This is used when you are using _front-to-back_ or _back-to-front_ method. Passenger will not board until the previous group is done boarding. 

### Revenue
1. Set the budget for each passenger on-ground operation.
2. Set terminal use fee. This fee is charged per passenger.
3. Set gate use fee. This fee is charged for the aircraft to use the gate.
4. Set landing/take off/ATC fee. This fee is charged for the aircraft to use the runway.
5. Set fixed-based operation fee. This fee is charged per ticks, for airplane parking, staffing, ground power, etc.
6. Set priority boarding fee. This is the revenue for airlines when passengers decided to pay to board earlier.

## THINGS TO NOTICE

When changing the size of the plane, remember also to change the number of passengers to make sure the plane is able to fit that many passengers. 

## THINGS TO TRY

Experiment with as many boarding strategies as you want. Run them on several different plane size. Is it always true that one is the best? Worst?

Experiment with _front-to-back_ and _back-to-front_ strategies. Run them with different boarding group sizes and different numbers of different rows. Is the result changing?

## EXTENDING THE MODEL

Is it possible to introduce more (or perhaps a unique) boarding strategy?
Is it possible to model if passengers go to the wrong seat which will further create the jam? 
Is it possible to model a travel group of passengers? Since normally passengers are on board with a few friends or familys.
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

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person graduate
false
0
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -8630108 true false 90 19 150 37 210 19 195 4 105 4
Polygon -8630108 true false 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -1184463 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -2674135 false 195 90 150 135
Line -2674135 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -2674135 false 208 22 208 57

person needassistant
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Rectangle -6459832 true false 240 60 255 270
Line -7500403 true 240 300 240 270
Line -7500403 true 255 300 255 270
Line -7500403 true 225 270 270 270
Line -7500403 true 225 270 225 300
Line -7500403 true 270 270 270 300

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

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
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>total-wait-time</metric>
    <metric>average-wait-time</metric>
    <metric>revenue</metric>
    <enumeratedValueSet variable="terminal-use-fee">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-of-priority-paid">
      <value value="2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-of-row" first="5" step="2" last="100"/>
    <enumeratedValueSet variable="fixed-base-operator">
      <value value="1.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="boarding-strategies">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-of-priority-military">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-luggage-per-passenger">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priority-boarding-fee">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="budget-for-ground-operation">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gate-use-fee">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="boarding-group-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="landing/takeoff/ATC-fee">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-of-priority-loyalty">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-of-priority-assistance">
      <value value="2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-of-seat-per-row" first="2" step="2" last="10"/>
    <enumeratedValueSet variable="number-of-passenger">
      <value value="1000"/>
    </enumeratedValueSet>
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
0
@#$#@#$#@
