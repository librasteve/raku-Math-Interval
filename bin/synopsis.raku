#!/usr/bin/env raku

use lib '../lib';
use Math::Interval;

my $r1 = 1..2;
my $r2 = 2..4;
my $r3 = -2..4;
my $r4 = 0..4;
my $r5 = -4..0;
my $r6 = 3..*;
my $r8 = '1'..'5';

#say $r1 ~~ Range:D;
say $r1 + $r2;
say $r1 + $r8;
say $r2 - $r1;
say $r2 * $r1;
say $r2 / $r1;
#say $r2 / $r3;
say $r2 / $r4;
say $r2 / $r5;
say $r2 / $r6;
