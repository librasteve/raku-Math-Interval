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

- ```x .. $y where $x & $y ~~ Any```
- to generate lists of consecutive numbers or strings
- to act as a matcher to check if a integer or string is within a
- certain range
- endpoints are Int with/out cats ears
- does Positional, does Iterable
- arithmetic +-*/ operators with scalars are distributed to endpoints like Junction with 2 elems, then each endpoint coerced to .Int
- prefix '+' special cased to .elems
- operator ```~~``` special cased to 'is contained by'
- coercer like .Num returns an Interval
- .Interval coerces endpoints to .Rat returns an Interval

### class Interval

- ```$x .. $y where $ & $y ~~ Real and $x | $y !~~ Int```
- to act as a matcher to check if a Numeric is within a certain range
- endpoints are Real, no cats ears
- not Iterable nor Positional
- arithmetic +-*/ operators with scalars are distributed to endpoints like Junction with 2 elems
- Rangy op Rangy --> Interval arithmetic +-*/ operators implemented
- Rangy ** N --> Interval operator implemented
- prefix '+' will fail (Interval has no .elems)
- operator ```~~``` special cased to 'is contained by'
- numeric cmp (<, <=, ==, !=, >, >=) work for Real op Rangy, Rangy op Real, Rangy op Rangy, when Range op Range, we check both endpoints to detect overlap in legal values so 1.0..2.0 < 2.0..3.0 False, 1.0..2.0 <= 2.0..3.0 True
- coercer like .Int or .Str returns a Range

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
- [ ] divide over zero -> disjoint multi-intervals
- [ ] 
- [ ] power (even / odd)
- [ ] log / exp
- [ ] trig
- [ ] Newton
### Comparison operators
### Set operators


### Copyright
copyright(c) 2023 Henley Cloud Consulting Ltd.