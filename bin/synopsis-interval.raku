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

# union ∪ [(|)] and intersection ∩ [(&)]
say $i4  ∪  $i3;
say $i3  ∩  $i4;    #∅ the null Set()

# gotchas
#say +$i1;          #fails - Interval has no .elems
#say $i1.Set;       #fails - raku Sets must contain discrete items
say $i1.Range.Set;  #coerce to Range to discretize an Interval

## the -Ofun bit

# division by an Intervals that spans 0 gives a disjoint multi-interval
my $j1 = (2..4)/(-2..4);
ddt $j1;            #any(-Inf..-1.0, 0.5..Inf).Junction
say 3 ~~ $j1;       #True  the result contains 3

# Junction[Interval] can still be used
my $j2 = $j1 + 2;
ddt $j2;            #any(-Inf..1.0, 2.5..Inf).Junction
say 5 ~~ $j2;

# but this can only go so far...
my $j3 = $j1 * (-2..4);
ddt $j3;            #any(-Inf..Inf, -Inf..Inf).Junction
say 3 ~~ $j3;

say ($i1,$i2,$i3,$i4).sort;





















