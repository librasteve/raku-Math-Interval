unit module Math::Interval:ver<0.0.1>:auth<Steve Roe (librasteve@furnival.net)>;
#viz. https://en.wikipedia.org/wiki/Interval_arithmetic
#viz. https://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node45.html

### This is a noddy implementation of Interval Arithmetic by overloading raku Range operators 
### No provision is made for Rounded Interval Arithmetic
### No provision is made for [disjoint] multi-intervals
### No provision is made for complex intervals

multi infix:<+>( Range:D $x, Range:D $y ) is export {
    my (\x1, \x2) = ($x.min, $x.max);
    my (\y1, \y2) = ($y.min, $y.max);

    (x1 + y1) .. (x2 + y2) 
}

multi infix:<->( Range:D $x, Range:D $y ) is export {
    my (\x1, \x2) = ($x.min, $x.max);
    my (\y1, \y2) = ($y.min, $y.max);

    (x1 - y2) .. (x2 - y1) 
}

multi infix:<*>( Range:D $x, Range:D $y ) is export {
    my @x = ($x.min, $x.max);
    my @y = ($y.min, $y.max);

    my @prods = @x X* @y;                   # make cross-prod, ie. x0*y0,x1*y0...

    @prods.min .. @prods.max
}

multi infix:</>( Range:D $x, Range:D $y ) is export {

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

    $x * inverse($y)
}

## TODOs
## Additional arithmetic operations
# power (even / odd)
# log / exp
# trig
## 

## Comparison operators 
## Set operators 
## need class Interval does Range {...} ?
