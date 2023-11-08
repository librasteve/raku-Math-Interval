[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

# Math::Interval

- viz. [https://en.wikipedia.org/wiki/Interval_arithmetic](https://en.wikipedia.org/wiki/Interval_arithmetic)
- viz. [https://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node45.html](https://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node45.html)

### A basic implementation of Interval Arithmetic using raku Ranges
- No provision is (yet) made for Rounded Interval Arithmetic
- No provision is (yet) made for complex intervals
- Only a handful of all possible Interval operations (eg. log, exp, trig) 
- No use of standard libs such as [MPRIA](https://www.gnu.org/software/mpria/) or [MPFI](https://metacpan.org/pod/Math::MPFI)

_Please feel free to submit any of these as a PR (see TODOs below)_


We split the use cases of the built-in Range type as follows:

### class Range

- ```$x1..$x2 where $x1 & $x2 ~~ Any```
- to generate lists of consecutive numbers or strings
- to act as a matcher to check if a integer or string is within a
- certain range
- endpoints are Int with/out cats ears
- does Positional, does Iterable
- arithmetic +-*/ operators with scalars are distributed to endpoints like Junction with 2 elems, then each endpoint coerced to .Int
- prefix '+' special cased to .elems
- use ```~~``` to check containment
  - ```say 3 ~~ 1..12;```    #True   x1 <= a <= x2
  - ```say 2..3 ~~ 1..12;``` #True   x1 >= y1 && x2 <= y2
  - ```say 1..12 ~~ 2..3;``` #False  (y must contain x)
- cmp works for Range op Range (for Real op Range .elems is used)
  - ```(0..2) cmp (0..12)``` #Less   x1 < x2 || x1 == x2 && y1 < y2
  - ```(0..2) cmp (0..2)```  #Same   x1 == x2 && y1 == y2
  - ```(1..2) cmp (0..12)``` #More   x1 > x2 || x1 == x2 && y1 > y2


### class Interval

- ```$x1..$x2 where $x1 & $x2 ~~ Real && $x2 >= $x1```
- to act as a matcher to check if a Numeric is within a certain range
- endpoints are Real, no cats ears, x2 >= x1
- not Iterable nor Positional
- arithmetic +-*/ operators with scalars are distributed to endpoints like Junction with 2 elems
- Rangy op Rangy --> Interval arithmetic +-*/ operators implemented
- Rangy ** N --> Interval operator implemented
- prefix '+' will fail (Interval has no .elems)
- use ```~~``` to check containment
  - ```say 3 ~~ 1..12;```    #True   x1 <= a <= x2
  - ```say 2..3 ~~ 1..12;``` #True   x1 >= y1 && x2 <= y2
  - ```say 1..12 ~~ 2..3;``` #False  (y must contain x)
- numeric cmp (<, <=, ==, !=, >, >=) work for Real op Rangy, Rangy op Real, Rangy op Rangy, when Range op Range, we check both endpoints to detect overlap in legal values so 1.0..2.0 < 2.0..3.0 False, 1.0..2.0 <= 2.0..3.0 True


Set & cmp operations:


compare (unlike Range, overlapping intervals are not ordered and yet not equal)
```(1..2) cmp (3..4)``` #Less    x2 < y1
```(1..2) cmp (2..4)``` #Nil     x2 !< y1                  !!    
```(0..2) cmp (0..2)``` #Same    x1 == x2 && y1 == y2
```(0..3) cmp (0..2)``` #Nil     x1 !> y2                  !!
```(3..4) cmp (1..2)``` #More    x1 > y2

Set operations
```#say $i1.Set;```            #fails - in general Sets contain discrete items and Intervals are continuous
```say $i1.Range.Set;```       #coerce to Range first and then use all Set operators (which auto-coerce that to Set)

However, the following two Set operations are supported for Intervals:


intersection (&) ∩
```∅```    if x1 > y2 || y1 > x2
```max(x1,y1)..min(x2,y2)```

union (|) ∪ (of two intersecting intervals)
```min(x1,y1)..max(x2,y2)```

other
```(3..4).abs```    #4   (always x2)
```(3..4).width```  #1   (x2-x1)

which leads to these design points:
- ```class Interval is Range {...}```
  - so can be used wherever a Range is used
  - noting lack of Iterator or Positional support
- ```Interval: new $range```
  - rejects non-Real endpoints (eg. Str)
  - adjusts endpoints (±1) to strip cats ears
- ```.Range``` coerces to Range
- ```subset Rangy of Any is export where * ~~ Range|Interval;```

## TODOs
### Additional arithmetic operations
- [ ] ~~ and cmp
- [ ] Set operators
- [ ] divide over zero -> disjoint multi-intervals
- [ ] power (even / odd)
- [ ] log / exp
- [ ] trig
- [ ] Newton
### Comparison operators
### Set operators


### Copyright
copyright(c) 2023 Henley Cloud Consulting Ltd.