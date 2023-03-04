#!/usr/bin/env perl
use strict;
use warnings;

# Play Christoffel word sets.

use Data::Dumper::Compact qw(ddc);
use lib map { "$ENV{HOME}/sandbox/$_/lib" } qw(MIDI-Drummer-Tiny Music-CreatingRhythms); # local author libs
use MIDI::Drummer::Tiny ();
use Music::CreatingRhythms ();

my $t = shift || 'u'; # type of word: u=upper, l=lower
my $p = shift || 2;   # numerator of slope
my $m = shift || 14;  # maximum denominator
my $n = shift || 16;  # number of terms to generate

my $max = shift || 4; # times to loop

my $mcr = Music::CreatingRhythms->new;

my $d = MIDI::Drummer::Tiny->new(
   file   => 'play-set.mid',
   bpm    => 90,
   volume => 100,
   bars   => 4,
   reverb => 15,
);

$d->sync(
    \&hihat,
    \&snare_drum,
    \&kick_drum,
);

$d->write;

sub hihat {
    my $sequence = [ (1) x 8 ];
    print 'Hihat: ', ddc($sequence, {max_width=>128});
    for (1 .. $max / 2) {
        for my $i (@$sequence) {
            $i ? $d->note('qn', $d->closed_hh) : $d->rest('qn');
        }
    }
}

sub snare_drum {
    my $q = int rand $m;
    my $sequence = $mcr->chsequl($t, $p, $q, $n);
    print 'Snare: ', ddc($sequence, {max_width=>128});
    for (1 .. $max) {
        for my $i (@$sequence) {
            $i ? $d->note('sn', $d->snare) : $d->rest('sn');
        }
    }
}

sub kick_drum {
    my $q = int rand $m;
    my $sequence = $mcr->chsequl($t, $p, $q, $n);
    print 'Kick:  ', ddc($sequence, {max_width=>128});
    for (1 .. $max) {
        for my $i (@$sequence) {
            $i ? $d->note('sn', $d->kick) : $d->rest('sn');
        }
    }
}
