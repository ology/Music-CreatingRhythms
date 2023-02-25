#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

my $module = 'Music::CreatingRhythms';

use_ok $module;

subtest basic => sub {
    my $mbv = new_ok $module => [
        verbose => 1,
    ];

    is $mbv->verbose, 1, 'verbose';
};

subtest debruijn_n => sub {
    my $mbv = new_ok $module;

    my $expect = [0];
    my $got = $mbv->debruijn_n(0);
    is_deeply $got, $expect, 'debruijn_n';

    $expect = [qw(1 0)];
    $got = $mbv->debruijn_n(1);
    is_deeply $got, $expect, 'debruijn_n';

    $expect = [qw(1 1 0 0)];
    $got = $mbv->debruijn_n(2);
    is_deeply $got, $expect, 'debruijn_n';

    $expect = [qw(1 1 1 0 1 0 0 0)];
    $got = $mbv->debruijn_n(3);
    is_deeply $got, $expect, 'debruijn_n';
};

subtest permute => sub {
    my $mbv = new_ok $module;

    my $parts = [qw(1 0 1)];

    my $expect = [[1,0,1],[1,1,0],[0,1,1],[0,1,1],[1,1,0],[1,0,1]];
    my $got = $mbv->permute($parts);
    is_deeply $got, $expect, 'permute';
};

subtest reverse_at => sub {
    my $mbv = new_ok $module;

    my $parts = [qw(1 0 1 0 0)];

    my $expect = [qw(0 0 1 0 1)];
    my $got = $mbv->reverse_at(0, $parts);
    is_deeply $got, $expect, 'reverse_at';

    $expect = [qw(1 0 0 1 0)];
    $got = $mbv->reverse_at(1, $parts);
    is_deeply $got, $expect, 'reverse_at';

    $expect = [qw(1 0 0 0 1)];
    $got = $mbv->reverse_at(2, $parts);
    is_deeply $got, $expect, 'reverse_at';

    $expect = [qw(1 0 1 0 0)];
    $got = $mbv->reverse_at(3, $parts);
    is_deeply $got, $expect, 'reverse_at';

    $expect = [qw(1 0 1 0 0)];
    $got = $mbv->reverse_at(4, $parts);
    is_deeply $got, $expect, 'reverse_at';
};

subtest rotate_n => sub {
    my $mbv = new_ok $module;

    my $parts = [qw(1 0 1 0 0)];

    my $expect = [qw(1 0 1 0 0)];
    my $got = $mbv->rotate_n(0, $parts);
    is_deeply $got, $expect, 'rotate_n';

    $expect = [qw(0 1 0 1 0)];
    $got = $mbv->rotate_n(1, $parts);
    is_deeply $got, $expect, 'rotate_n';

    $expect = [qw(0 0 1 0 1)];
    $got = $mbv->rotate_n(2, $parts);
    is_deeply $got, $expect, 'rotate_n';

    $expect = [qw(1 0 0 1 0)];
    $got = $mbv->rotate_n(3, $parts);
    is_deeply $got, $expect, 'rotate_n';

    $expect = [qw(0 1 0 0 1)];
    $got = $mbv->rotate_n(4, $parts);
    is_deeply $got, $expect, 'rotate_n';

    $expect = [qw(1 0 1 0 0)];
    $got = $mbv->rotate_n(5, $parts);
    is_deeply $got, $expect, 'rotate_n';
};

done_testing();
