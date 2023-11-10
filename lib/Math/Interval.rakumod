unit module Math::Interval:ver<0.0.2>:auth<Steve Roe (librasteve@furnival.net)>;
#viz. https://en.wikipedia.org/wiki/Interval_arithmetic
#viz. https://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node45.html

class Interval {...}

#| Rangy helps multi infix operators to take both Range & Interval types
subset Rangy of Any is export where * ~~ Range|Interval;

#| Add method for coercion of Range to Interval
use MONKEY-TYPING;

augment class Range {
    method Interval(Range:D:) {
        Interval.new: self.min..self.max
    }
}

#| Interval is a child of class Range where endpoints are always Numeric
#| No cats ears, not Positional, not Iterable, no .elems
class Interval is Range is export {

    has Range $!range is built
        handles <min max minmax bounds infinite raku gist fmt>; #not WHICH of?

    submethod TWEAK {
        my ($x1, $x2) = $!range.min, $!range.max;

        die "x1 <= x2 is required for Interval endpoints" unless $x1 <= $x2;

        #| clean out cats ears
        $x1 += $!range.excludes-min;                            #\ True=1/
        $x2 -= $!range.excludes-max;                            #/ False=0

        #| reject Str endpoints
        $!range = $x1.Numeric..$x2.Numeric;
    }

    multi method new( Range:D(Interval:D) :$range ) {           # Named -> Range
        self.bless: :$range
    }

    multi method new( Rangy:D $range ) {                        # Positional -> Named
        self.new: :$range
    }

    multi method new( Numeric:D() $x1, Numeric:D() $x2 ) {      # Endpoints
        self.new: $x1..$x2
    }

    method Range( --> Range ) { $!range }

    multi method ACCEPTS(Interval:D: Real:D $x ) {
        $!range.ACCEPTS: $x
    }

    multi method ACCEPTS(Interval:D: Interval:D $x ) {
        $!range.ACCEPTS: $x.Range
    }

    method FALLBACK( $name ) {
        die "method .$name is not provided for class Interval"
    }

    method abs {
        $!range.max
    }

    method width {
        $!range.max - $!range.min
    }
}

my class Operation {
    #| initialize xy terms by binding to scalar args
    my (\x1, \x2, \y1, \y2) := my ($x1, $x2, $y1, $y2);

    has $.x;
    has $.y;
    has @!xXy;

    submethod TWEAK {
        #| load xy terms via the scalars
        ($x1, $x2) = ($!x.min, $!x.max);
        ($y1, $y2) = ($!y.min, $!y.max);

        #| make cross product, ie. x0*y0,x1*y0...
        @!xXy = (x1, x2) X* (y1, y2);
    }

    #| make inverse, ie. 1/[y1..y2]
    sub inverse($y) {
        my \ss = (y1.sign == y2.sign);      # same sign

        given       y1, y2  {
            # continuous
            when    !0, !0  &&  ss  { Interval.new: 1/y2 .. 1/y1 }
            when    !0,  0          { Interval.new: -Inf .. 1/y1 }
            when     0, !0          { Interval.new: 1/y2 .. Inf  }

            # disjoint
            when    !0, !0  && !ss  {
                warn "divisor contains 0, returning a multi Interval Junction";
                Interval.new(-Inf..1/y1) | Interval.new(1/y2..Inf)
            }

            # div 0 error
            when     0,  0          { die "divisor cannot be 0..0. Divide by zero attempt." }
        }
    }

    method add {
        Interval.new: (x1 + y1) .. (x2 + y2)
    }

    method sub {
        Interval.new: (x1 - y2) .. (x2 - y1)
    }

    method mul {
        Interval.new: @!xXy.min .. @!xXy.max
    }

    method div {
        Interval.new: $!x * inverse($!y)
    }

    method union {
        Interval.new: min(x1,y1) .. max(x2,y2)
    }

    method intersection {
        if x1 > y2 || y1 > x2 {
            ∅  # the null Set
        } else {
            Interval.new: max(x1,y1) .. min(x2,y2)
        }
    }

    method cmp {
        if x1==y1 && x2==y2 {
            Same
        } elsif x2 < y1 {
            Less
        } elsif y2 < x1 {
            More
        } else {   # overlaps are unordered and not equal
            Nil
        }
    }
}

## Basic Arithmetic Operators (+-*/)
multi infix:<+>( Rangy:D $x, Rangy:D $y ) is export {
    Operation.new(:$x, :$y).add
}

multi infix:<->( Rangy:D $x, Rangy:D $y ) is export {
    Operation.new(:$x, :$y).sub
}

multi infix:<*>( Rangy:D $x, Rangy:D $y ) is export {
    Operation.new(:$x, :$y).mul
}

multi infix:</>( Rangy:D $x, Rangy:D $y ) is export {
    Operation.new(:$x, :$y).div
}

## Set Operators
multi infix:<(&)>( Interval:D $x, Interval:D $y ) is export {
    Operation.new(:$x, :$y).intersection
}
multi infix:<∩>(   Interval:D $x, Interval:D $y ) is export {
    Operation.new(:$x, :$y).intersection
}

multi infix:<(|)>( Interval:D $x, Interval:D $y ) is export {
    Operation.new(:$x, :$y).union
}
multi infix:<∪>(   Interval:D $x, Interval:D $y ) is export {
    Operation.new(:$x, :$y).union
}

## Comparison Operators
multi infix:<cmp>( Interval:D $x, Interval:D $y ) is export {
    Operation.new(:$x, :$y).cmp
}

