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
