#!/usr/bin/env perl
use strict;
use warnings;

# Generate Christoffel word sets.

use Data::Dumper::Compact qw(ddc);
use Music::CreatingRhythms ();

my $m = shift || 16;  # maximum iteration

my $mcr = Music::CreatingRhythms->new;

for my $i (0 .. $m - 1) {
    my $sequence = $mcr->pfold(15, 4, $i);
    print ddc($sequence, {max_width=>128});
}
