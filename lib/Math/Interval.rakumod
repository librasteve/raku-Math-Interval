unit module Math::Interval:ver<0.0.1>:auth<Steve Roe (librasteve@furnival.net)>;
#viz. https://en.wikipedia.org/wiki/Interval_arithmetic
#viz. https://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node45.html

##  A noddy implementation of Interval Arithmetic using raku Ranges
### No provision is made for Rounded Interval Arithmetic
### No provision is made for [disjoint] multi-intervals
### No provision is made for complex intervals

class Interval {...}
subset Rangy of Any where * ~~ Range|Interval;

#| Interval is a subclass of Range where endpoints are always Numeric
#|  [in anticipation of Rounded Interval Arithmetic]
#|  [https://en.wikipedia.org/wiki/Interval_arithmetic#Rounded_interval_arithmetic]
#| No cats ears, not Positional, not Iterable
#| Interval methods may work with Junctions of Intervals (tbd)
class Interval is export {
#    try Range(Interval) maybe
    has Range $.range handles <min max minmax bounds infinite raku gist fmt>;

    submethod TWEAK {
        my ($x1, $x2) = $!range.min, $!range.max;

        #| clean out cats ears
        $x1 += $!range.excludes-min;
        $x2 -= $!range.excludes-max;

        #| coerce to Numeric
        $!range = $x1.Numeric..$x2.Numeric
    }

    multi method new( Range:D $range ) {               # Positional -> Named
        Interval.new: :$range
    }

    multi method new( Interval:D $interval ) {         # Positional -> Named
        Interval.new: range => $interval.Range
    }

    multi method new( Interval:D :$range ) {           # Named
        Interval.new: range => $range.Range
    }

    multi method new( Numeric:D $x1, Numeric:D $x2 ) {
        die ".new requires both endpoints to be Num" unless $x1 & $x2 ~~ Num;
        Interval.new: $x1.Num..$x2.Num
    }

    method Range { $!range }

#    method WHAT { Interval }                           #FIXME dont work!

    method FALLBACK( $name ) {
        die "method .$name is not provided for class Interval"

    }
}

## Rangy op Rangy operators
## return an Interval (which can be coerced back to a Range)

multi infix:<+>( Rangy:D $x, Rangy:D $y --> Interval ) is export {
    my (\x1, \x2) = ($x.min, $x.max);
    my (\y1, \y2) = ($y.min, $y.max);

    Interval.new: (x1 + y1) .. (x2 + y2)
}

multi infix:<->( Rangy:D $x, Rangy:D $y --> Interval ) is export {
    my (\x1, \x2) = ($x.min, $x.max);
    my (\y1, \y2) = ($y.min, $y.max);

    Interval.new: (x1 - y2) .. (x2 - y1)
}

multi infix:<*>( Rangy:D $x, Rangy:D $y --> Interval ) is export {
    my @x = ($x.min, $x.max);
    my @y = ($y.min, $y.max);

    my @prods = @x X* @y;                   # make cross-prod, ie. x0*y0,x1*y0...

    Interval.new: @prods.min .. @prods.max
}

multi infix:</>( Rangy:D $x, Rangy:D $y --> Interval ) is export {

    sub inverse($y) {                       # make inverse, ie. 1/[y1..y2] 
        my (\y1, \y2) = ($y.min, $y.max);
        my \ss = (y1.sign == y2.sign);      # same sign

        given y1, y2  {
            # valid 
            when    !0, !0  &&  ss  { 1/y2 .. 1/y1 }
            when    !0,  0          { -Inf .. 1/y1 }
            when     0, !0          { 1/y2 .. Inf  }

            # error
            when     0,  0          { die "Divisor cannot be Range 0..0. Divide by zero attempt." } 
            when    !0, !0  && !ss  { die "Divisor cannot be Range that spans 0 [multi-intervals are not supported]." }
        }
    }

    Interval.new: $x * inverse($y)
}


