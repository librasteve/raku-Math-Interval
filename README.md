[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

## Math::Interval

- viz. [https://en.wikipedia.org/wiki/Interval_arithmetic](https://en.wikipedia.org/wiki/Interval_arithmetic)
- viz. [https://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node45.html](https://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node45.html)

### A elementary implementation of Interval Arithmetic using raku Ranges

Check out the Wikipedia page first - sub and div may confound your expectations:

## Synopsis

```perl6
#!/usr/bin/env raku
use lib '../lib';

use Data::Dump::Tree;
use Math::Interval;

# Range-Range Operations use interval math
say (1..2) + (2..4);        #3..6
say (2..4) - (1..2);        #0..3  (yes - this is weird!)
say (2..4) * (1..2);        #2..8
say (2..4) / (1..2);        #1.0..4.0
# strings work too! (must be numbers)
say (1..2) + ('1'..'5');    #2..7
# an Interval is returned
say ((1..2) + (2..4)) ~~ Interval;  #True

#| Interval is a child of class Range where endpoints are always Numeric
#| No cats ears, not Positional, not Iterable, no .elems
my Interval $i1 .= new(range => 2.5^..^8.5);    #3.5..7.5
my Interval $i2 .= new(2..^8);                  #2e0..7e0
my Interval $i3 .= new(1,2);                    #1..2
my Interval $i4 .= new(4.5,6.5);                #4.5..6.5

# '~~' checks if y contains x
say   2 ~~ $i2;     #True
say $i4 ~~ $i1;     #True
say $i1 ~~ $i4;     #False

# cmp checks Order
say $i1 cmp $i1;    #Same
say $i1 cmp $i3;    #More
say $i3 cmp $i1;    #Less
say $i1 cmp $i2;    #Nil   overlaps are not ordered
say $i2 cmp $i1;    #Nil            ""

# intersection ∩ [(&)] and union ∪ [(|)] 
say $i3  ∩  $i4;    #∅ the null Set()
say $i4  ∪  $i3;    #union returns a disjoint multi-interval unless args intersect

# gotchas
#say +$i1;          #fails - Interval has no .elems
#say $i1.Set;       #fails - raku Sets must contain discrete items
say $i1.Range.Set;  #coerce to Range to discretize an Interval

## the -Ofun bit

# a divisor that spans 0 produces a disjoint multi-interval
my $j1 = (2..4)/(-2..4);
ddt $j1;            #any(-Inf..-1.0, 0.5..Inf).Junction
say 3 ~~ $j1;       #True

# Junction[Interval] can still be used
my $j2 = $j1 + 2;
ddt $j2;            #any(-Inf..1.0, 2.5..Inf).Junction
say 5 ~~ $j2;       #True

# but this can only go so far...
my $j3 = $j1 * (-2..4);
ddt $j3;            #any(-Inf..Inf, -Inf..Inf).Junction
say 3 ~~ $j3;       #True (but meaningless!)
```

## Explanation

We split the use cases of the built-in Range type as follows:

### class Range

- Use case
  - to generate lists of consecutive numbers or strings
  - to act as a matcher to check if a Numeric or Stringy or Range is within a certain Range
- endpoints with/out cats ears (±1)
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
- Set operations work for Any op Range and Range op Range by auto coercing both args via ```.Set``` 


### class Interval

- Use case
  - to act as a matcher to check if a Numeric or Interval is within a certain range
- endpoints will ingest cats ears, x1 <= x2
- not Iterable nor Positional
- arithmetic +-*/ operators with scalars are distributed to endpoints like Junction with 2 elems
- Rangy op Rangy --> Interval arithmetic +-*/ operators implemented
- Rangy ** N --> Interval operator implemented
- prefix '+' will fail (Interval has no .elems)
- use ```~~``` to check containment
  - ```say 3 ~~ 1..12;```    #True   x1 <= a <= x2
  - ```say 2..3 ~~ 1..12;``` #True   x1 >= y1 && x2 <= y2
  - ```say 1..12 ~~ 2..3;``` #False  (y must contain x)
- cmp works for Interval op Interval
  - UNLIKE Range, overlapping intervals are not ordered and yet not equal
  - ```(1..2) cmp (3..4)``` #Less    x2 < y1
  - ```(1..2) cmp (2..4)``` #Nil     x2 !< y1                  !!    
  - ```(0..2) cmp (0..2)``` #Same    x1 == x2 && y1 == y2
  - ```(0..3) cmp (0..2)``` #Nil     x1 !> y2                  !!
  - ```(3..4) cmp (1..2)``` #More    x1 > y2

Set operations
```#say $i1.Set;```            #fails - in general Sets contain discrete items and Intervals are continuous
```say $i1.Range.Set;```       #coerce to Range first to use all Set operators (which discretizes the Interval)

However, the following two Set operations are implemented for Intervals:

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
- ```subset Rangy of Any where * ~~ Range|Interval;```

- No provision is (yet) made for Rounded Interval Arithmetic
- No provision is (yet) made for complex intervals
- Only a handful of all possible Interval operations (eg. log, exp, trig)
- No use of standard libs such as [MPRIA](https://www.gnu.org/software/mpria/) or [MPFI](https://metacpan.org/pod/Math::MPFI)

_Please feel free to submit any of these as a PR (see TODOs below)_

## TODOs
### Additional arithmetic operations
- [ ] power (even / odd)
- [ ] log / exp
- [ ] trig
- [ ] Newton

### Copyright
copyright(c) 2023 Henley Cloud Consulting Ltd.