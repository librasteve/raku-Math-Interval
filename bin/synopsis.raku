#!/usr/bin/env raku

use lib '../lib';
use Math::Interval;

my $r1 = 1..2;
my $r2 = 2..4;
my $r3 = -2..4;
my $r4 = 0..4;
my $r5 = -4..0;
my $r6 = 3..*;
my $r7 = 0..0;
my $r8 = '1'..'5';

# Range op Range for +-*/
say $r1 + $r2;    #3..6
say $r2 - $r1;    #0.3.
say $r2 * $r1;    #2..8
say $r2 / $r1;    #1.0..4.0

# some divide errors and corner cases
#say $r2 / $r3;   # dies ($r3 spans 0)
say $r2 / $r4;    #0.5..Inf
say $r2 / $r5;    #-Inf..-0.5
say $r2 / $r6;    #0e0..<4/3>
say $r2 / $r7;    #<1/0>..<1/0>

# numeric strings work too!
say $r1 + $r8;    #2..7

#cat ears and whatever and whatever codes are collapsed

my Interval $i1 .= new(range => 2.5^..^8.5);    #3.5..7.5
my Interval $i2 .= new(2..^8);                  #2e0..7e0
#my Interval $i3 .= new('a'..'z');               #dies
my Interval $i4 .= new(1,2);                    #1..2
my Interval $i5 .= new($i1);                  #2e0..7e0

say '---';
say $i1, $i2, $i4, $i5;


my @methods = <min max minmax bounds infinite raku gist fmt Range>;
{ say "$^method makes: ", $i1."$^method"() } for @methods;

my $i6 = $i1 + 4;
say $i6;

my $i7 = $i1 + $i2;
say $i7;

#say +$i1;    #fails
#say $i1.Set;           #fails - in general raku Sets contain discrete items and Intervals are continuous
say $i1.Range.Set;       #coerce to Range first and then use all Set operators

my Interval $i8 .= new(4.5,6.5);

say 2 ~~ $i2;
say 0 ~~ $i2;
say 2.4 ~~ $i1;
say 3.5 ~~ $i1;



say $i8 ~~ $i1;
say $i1 ~~ $i8;

say $i1 ~~ $i1;
say $i2 ~~ $i1;
say $i1 ~~ $i2;
say $i8 ~~ $i1;
say $i1 ~~ $i8;

say $i1 cmp $i1;
say $i1 cmp $i2;
say $i2 cmp $i1;
say $i1 cmp $i4;
say $i4 cmp $i1;

say $i1 (&) $i1;
say $i1 (&) $i2;
say $i2 (&) $i1;
say $i2 ∩ $i4;
say $i4 ∩ $i8;

say $i2.abs;
say $i2.width;




#iamerejh

















