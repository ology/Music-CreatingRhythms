#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

my $module = 'Music::CreatingRhythms';

use_ok $module;

subtest basic => sub {
    my $mcr = new_ok $module => [
        verbose => 1,
    ];

    is $mcr->verbose, 1, 'verbose';
};

subtest comp => sub {
    my $mcr = new_ok $module;

    my $expect = [[1]];
    my $got = $mcr->comp(1);
    is_deeply $got, $expect, 'comp';

    $expect = [[1,1],[2]];
    $got = $mcr->comp(2);
    is_deeply $got, $expect, 'comp';

    $expect = [[1,1,1],[1,2],[2,1],[3]];
    $got = $mcr->comp(3);
    is_deeply $got, $expect, 'comp';

    $expect = [[1,1,1,1],[1,1,2],[1,2,1],[1,3],[2,1,1],[2,2],[3,1],[4]];
    $got = $mcr->comp(4);
    is_deeply $got, $expect, 'comp';
};

subtest compm => sub {
    my $mcr = new_ok $module;

    my $expect = [[1]];
    my $got = $mcr->compm(1, 1);
    is_deeply $got, $expect, 'compm';

    $expect = [];
    $got = $mcr->compm(1, 2);
    is_deeply $got, $expect, 'compm';

    $expect = [[1,1]];
    $got = $mcr->compm(2, 2);
    is_deeply $got, $expect, 'compm';

    $expect = [[1,2],[2,1]];
    $got = $mcr->compm(3, 2);
    is_deeply $got, $expect, 'compm';

    $expect = [[1,3],[2,2],[3,1]];
    $got = $mcr->compm(4, 2);
    is_deeply $got, $expect, 'compm';

    $expect = [[1,4],[2,3],[3,2],[4,1]];
    $got = $mcr->compm(5, 2);
    is_deeply $got, $expect, 'compm';

    $expect = [[1,5],[2,4],[3,3],[4,2],[5,1]];
    $got = $mcr->compm(6, 2);
    is_deeply $got, $expect, 'compm';
};

subtest debruijn_n => sub {
    my $mcr = new_ok $module;

    my $expect = [0];
    my $got = $mcr->debruijn_n(0);
    is_deeply $got, $expect, 'debruijn_n';

    $expect = [qw(1 0)];
    $got = $mcr->debruijn_n(1);
    is_deeply $got, $expect, 'debruijn_n';

    $expect = [qw(1 1 0 0)];
    $got = $mcr->debruijn_n(2);
    is_deeply $got, $expect, 'debruijn_n';

    $expect = [qw(1 1 1 0 1 0 0 0)];
    $got = $mcr->debruijn_n(3);
    is_deeply $got, $expect, 'debruijn_n';
};

subtest part => sub {
    my $mcr = new_ok $module;

    my $expect = [[1]];
    my $got = $mcr->part(1);
    is_deeply $got, $expect, 'part';

    $expect = [[1,1],[2]];
    $got = $mcr->part(2);
    is_deeply $got, $expect, 'part';

    $expect = [[1,1,1],[1,2],[3]];
    $got = $mcr->part(3);
    is_deeply $got, $expect, 'part';

    $expect = [[1,1,1,1],[1,1,2],[2,2],[1,3],[4]];
    $got = $mcr->part(4);
    is_deeply $got, $expect, 'part';
};

subtest parta => sub {
    my $mcr = new_ok $module;

    my $expect = [[1]];
    my $got = $mcr->parta(1, 1);
    is_deeply $got, $expect, 'parta';

    $expect = [];
    $got = $mcr->parta(1, 2);
    is_deeply $got, $expect, 'parta';

    $expect = [[2]];
    $got = $mcr->parta(2, 2);
    is_deeply $got, $expect, 'parta';

    $expect = [[1,1,1]];
    $got = $mcr->parta(3, 1);
    is_deeply $got, $expect, 'parta';

    $expect = [[1,1,1,1]];
    $got = $mcr->parta(4, 1);
    is_deeply $got, $expect, 'parta';

    $expect = [[1,1,1,1],[1,1,2],[2,2]];
    $got = $mcr->parta(4, 1,2);
    is_deeply $got, $expect, 'parta';

    $expect = [[1,1,1,1],[1,1,2],[2,2],[1,3]];
    $got = $mcr->parta(4, 1,2,3);
    is_deeply $got, $expect, 'parta';
};

subtest partam => sub {
    my $mcr = new_ok $module;

    my $expect = [[1]];
    my $got = $mcr->partam(1, 1, 1);
    is_deeply $got, $expect, 'partam';

    $expect = [];
    $got = $mcr->partam(1, 2, 1);
    is_deeply $got, $expect, 'partam';

    $expect = [[1,1]];
    $got = $mcr->partam(2, 2, 1);
    is_deeply $got, $expect, 'partam';

    $expect = [[1,1,1]];
    $got = $mcr->partam(3, 3, 1);
    is_deeply $got, $expect, 'partam';

    $expect = [[1,1,1,1]];
    $got = $mcr->partam(4, 4, 1);
    is_deeply $got, $expect, 'partam';

    $expect = [[1,1,2]];
    $got = $mcr->partam(4, 3, 1,2);
    is_deeply $got, $expect, 'partam';

    $expect = [[1,3],[2,2]];
    $got = $mcr->partam(4, 2, 1,2,3);
    is_deeply $got, $expect, 'partam';
};

subtest partm => sub {
    my $mcr = new_ok $module;

    my $expect = [[1]];
    my $got = $mcr->partm(1, 1);
    is_deeply $got, $expect, 'partm';

    $expect = [];
    $got = $mcr->partm(1, 2);
    is_deeply $got, $expect, 'partm';

    $expect = [[1,1]];
    $got = $mcr->partm(2, 2);
    is_deeply $got, $expect, 'partm';

    $expect = [[1,2]];
    $got = $mcr->partm(3, 2);
    is_deeply $got, $expect, 'partm';

    $expect = [[1,3],[2,2]];
    $got = $mcr->partm(4, 2);
    is_deeply $got, $expect, 'partm';

    $expect = [[1,4],[2,3]];
    $got = $mcr->partm(5, 2);
    is_deeply $got, $expect, 'partm';

    $expect = [[1,5],[2,4],[3,3]];
    $got = $mcr->partm(6, 2);
    is_deeply $got, $expect, 'partm';
};

subtest permute => sub {
    my $mcr = new_ok $module;

    my $parts = [qw(1 0 1)];

    my $expect = [[1,0,1],[1,1,0],[0,1,1],[0,1,1],[1,1,0],[1,0,1]];
    my $got = $mcr->permute($parts);
    is_deeply $got, $expect, 'permute';
};

subtest reverse_at => sub {
    my $mcr = new_ok $module;

    my $parts = [qw(1 0 1 0 0)];

    my $expect = [qw(0 0 1 0 1)];
    my $got = $mcr->reverse_at(0, $parts);
    is_deeply $got, $expect, 'reverse_at';

    $expect = [qw(1 0 0 1 0)];
    $got = $mcr->reverse_at(1, $parts);
    is_deeply $got, $expect, 'reverse_at';

    $expect = [qw(1 0 0 0 1)];
    $got = $mcr->reverse_at(2, $parts);
    is_deeply $got, $expect, 'reverse_at';

    $expect = [qw(1 0 1 0 0)];
    $got = $mcr->reverse_at(3, $parts);
    is_deeply $got, $expect, 'reverse_at';

    $expect = [qw(1 0 1 0 0)];
    $got = $mcr->reverse_at(4, $parts);
    is_deeply $got, $expect, 'reverse_at';
};

subtest rotate_n => sub {
    my $mcr = new_ok $module;

    my $parts = [qw(1 0 1 0 0)];

    my $expect = [qw(1 0 1 0 0)];
    my $got = $mcr->rotate_n(0, $parts);
    is_deeply $got, $expect, 'rotate_n';

    $expect = [qw(0 1 0 1 0)];
    $got = $mcr->rotate_n(1, $parts);
    is_deeply $got, $expect, 'rotate_n';

    $expect = [qw(0 0 1 0 1)];
    $got = $mcr->rotate_n(2, $parts);
    is_deeply $got, $expect, 'rotate_n';

    $expect = [qw(1 0 0 1 0)];
    $got = $mcr->rotate_n(3, $parts);
    is_deeply $got, $expect, 'rotate_n';

    $expect = [qw(0 1 0 0 1)];
    $got = $mcr->rotate_n(4, $parts);
    is_deeply $got, $expect, 'rotate_n';

    $expect = [qw(1 0 1 0 0)];
    $got = $mcr->rotate_n(5, $parts);
    is_deeply $got, $expect, 'rotate_n';
};

done_testing();
