package Music::CreatingRhythms;

# ABSTRACT: Ported Perl from the book's C code

our $VERSION = '0.0101';

use Moo;
use strictures 2;
use Algorithm::Combinatorics qw(permutations);
use Carp qw(croak);
use Data::Munge qw(list2re);
use Integer::Partition ();
use List::Util qw(all any);
use Math::NumSeq::SqrtContinued ();
use Math::Sequence::DeBruijn qw(debruijn);
use Music::AtonalUtil ();
use namespace::clean;

=head1 SYNOPSIS

  use Music::CreatingRhythms ();
  my $mcr = Music::CreatingRhythms->new;
  my $foo = $mcr->foo('...');

=head1 DESCRIPTION

C<Music::CreatingRhythms> provides the combinatorial algorithms
described in the book, "Creating Rhythms", by Hollos. These algorithms
are ported directly from the C, and are pretty fast. Please see the
link below for more information.

NB: Arguments are sometimes switched between book and software.

Additionally, this module provides utilities that are not part of the
book, but are nonetheless handy.

=head1 ATTRIBUTES

=head2 verbose

  $verbose = $mcr->verbose;

Show progress. * This is not showing anything yet, however.

=cut

has verbose => (
    is      => 'ro',
    isa     => sub { croak "$_[0] is not a boolean" unless $_[0] =~ /^[01]$/ },
    default => sub { 0 },
);

=head1 METHODS

=head2 new

  $mcr = Music::CreatingRhythms->new;

Create a new C<Music::CreatingRhythms> object.

=for Pod::Coverage BUILD

=cut

=head2 cfsqrt

  $sequence = $mcr->cfsqrt($n, $m);

Calculate the continued fraction for C<sqrt(n)> to B<m> digits, where
B<n> and B<m> are integers.

=cut

sub cfsqrt {
    my ($self, $n, $m) = @_;
    $m ||= $n;
    my @terms;
    my $seq = Math::NumSeq::SqrtContinued->new(sqrt => $n);
    for my $i (1 .. $m) {
        my ($i, $value) = $seq->next;
        push @terms, $value;
    }
    return \@terms;
}

=head2 chsequl

  $sequence = $mcr->chsequl($t, $p, $q);
  $sequence = $mcr->chsequl($t, $p, $q, $n);

Generate the upper or lower Christoffel word for B<p> and B<q>.

Arguments:

  $t: required type of word (u: upper, l: lower)
  $p: required numerator of slope
  $q: required denominator of slope
  $n: optional number of terms to generate, default: p+q

=cut

sub chsequl {
    my ($self, $t, $p, $q, $n) = @_;
    die "Usage: chsequl(\$type, \$numerator, \$denominator [\$terms])\n"
        unless $t && defined $p && defined $q;
    $n ||= $p + $q;
    my @word;
    my $i = 0;
    while ($i < $n) {
        push @word, $t eq 'u' ? 1 : 0;
        $i++;
        my ($x, $y) = ($p, $q);
        while ($x != $y && $i < $n) {
            if ($x > $y) {
                push @word, 1;
                $y += $q;
            }
            else {
                push @word, 0;
                $x += $p;
            }
            $i++;
        }
        if ($x == $y && $i < $n) {
            push @word, $t eq 'u' ? 0 : 1;
            $i++;
        }
    }
    return \@word;
}

=head2 comp

  $compositions = $mcr->comp($n);

Generate all compositions of B<n>.

=cut

sub comp {
    my ($self, $n) = @_;
    my @compositions;
    my @parts;
    my $i = 0;
    _compose($n - 1, 1, 0, \$i, \@compositions, \@parts);
    return \@compositions;
}

sub _compose {
    my ($n, $p, $k, $i, $compositions, $parts) = @_;
    if ($n == 0) {
        while ($n < $k) {
            push @{ $compositions->[$$i] }, $parts->[$n];
            $n++;
        }
        push @{ $compositions->[$$i] }, $p;
        $$i++;
        return;
    }
    $parts->[$k] = $p;
    _compose($n - 1, 1, $k + 1, $i, $compositions, $parts);
    _compose($n - 1, $p + 1, $k, $i, $compositions, $parts);
}

=head2 compa

  $compositions = $mcr->compa($n, @intervals);

Generate compositions of B<n> with allowed intervals
B<p1, p2, ... pn>.

=cut

sub compa {
    my ($self, $n, @intervals) = @_;
    my @compositions;
    my @parts;
    my $i = 0;
    _composea($n - 1, 1, 0, \$i, \@compositions, \@parts, \@intervals);
    return \@compositions;
}

sub _composea {
  my ($n, $p, $k, $i, $compositions, $parts, $intervals) = @_;
  if ($n == 0) {
    if (_allowed($p, $intervals)) {
      while ($n < $k) {
        push @{ $compositions->[$$i] }, $parts->[$n];
        $n++;
      }
      push @{ $compositions->[$$i] }, $p;
      $$i++;
    }
    return;
  }
  if (_allowed($p, $intervals)) {
    $parts->[$k] = $p;
    _composea($n - 1, 1, $k + 1, $i, $compositions, $parts, $intervals);
  }
  _composea($n - 1, $p + 1, $k, $i, $compositions, $parts, $intervals);
}

=head2 compam

  $compositions = $mcr->compam($n, $m, @intervals);

Generate compositions of B<n> with B<m> parts and allowed intervals
B<p1, p2, ... pn>.

=cut

sub compam {
    my ($self, $n, $m, @intervals) = @_;
    $m--;
    my @compositions;
    my @parts;
    my $i = 0;
    _composeam($n - 1, 1, 0, $m, \$i, \@compositions, \@parts, \@intervals);
    return \@compositions;
}

sub _composeam {
  my ($n, $p, $k, $m, $i, $compositions, $parts, $intervals) = @_;
  if ($n == 0) {
    if ($k == $m && _allowed($p, $intervals)) {
      while ($n < $k) {
        push @{ $compositions->[$$i] }, $parts->[$n];
        $n++;
      }
      push @{ $compositions->[$$i] }, $p;
      $$i++;
    }
    return;
  }
  if ($k < $m && _allowed($p, $intervals)) {
    $parts->[$k] = $p;
    _composeam($n - 1, 1, $k + 1, $m, $i, $compositions, $parts, $intervals);
  }
  _composeam($n - 1, $p + 1, $k, $m, $i, $compositions, $parts, $intervals);
}

=head2 compm

  $compositions = $mcr->compm($n, $m);

Generate all compositions of B<n> into B<m> parts.

=cut

sub compm {
    my ($self, $n, $m) = @_;
    $m--;
    my @compositions;
    my @parts;
    my $i = 0;
    _composem($n - 1, 1, 0, $m, \$i, \@compositions, \@parts);
    return \@compositions;
}

sub _composem {
    my ($n, $p, $k, $m, $i, $compositions, $parts) = @_;
    if ($n == 0) {
        if ($k == $m) {
            while ($n < $k) {
                push @{ $compositions->[$$i] }, $parts->[$n];
                $n++;
            }
            push @{ $compositions->[$$i] }, $p;
            $$i++;
        }
        return;
    }
    if ($k < $m) {
        $parts->[$k] = $p;
        _composem($n - 1, 1, $k + 1, $m, $i, $compositions, $parts);
    }
    _composem($n - 1, $p + 1, $k, $m, $i, $compositions, $parts);
}

=head2 debruijn_n

  $sequence = $mcr->debruijn_n($n);

Generate the largest de Bruijn sequence of order B<n>.

=cut

sub debruijn_n {
    my ($self, $n) = @_;
    my $sequence = $n ? debruijn([1,0], $n) : 0;
    return [ split //, $sequence ];
}

=head2 euclid

  $sequence = $mcr->euclid($n, $m);

Generate a Euclidean rhythm given B<n> onsets distributed over B<m>
beats.

=cut

sub euclid {
    my ($self, $n, $m) = @_;
    my $intercept = 1;
    my $slope = $n / $m;
    my @pattern = ('0') x $m;
    for my $y ( 1 .. $n ) {
        $pattern[ sprintf '%.0f', ( $y - $intercept ) / $slope ] = '1';
    }
    return \@pattern;
}

=head2 invert_at

  $sequence = $mcr->invert_at($n, $parts);

Invert a section of a B<parts> binary sequence at B<n>.

=cut

sub invert_at {
    my ($self, $n, $parts) = @_;
    my @head = @$parts[ 0 .. $n - 1 ];
    my @tail = map { $_ ? 0 : 1 } @$parts[ $n .. $#$parts ];
    my @data = (@head, @tail);
    return \@data;
}

=head2 neck

  $necklaces = $mcr->neck($n);

Generate all binary necklaces of length B<n>.

=cut

sub neck {
    my ($self, $n) = @_;
    my @necklaces;
    my @parts = (1);
    my $i = 0;
    _neckbin($n, 1, 1, \$i, \@necklaces, \@parts);
    return \@necklaces;
}

sub _neckbin {
    my ($n, $k, $l, $i, $necklaces, $parts) = @_;
    # k = length of necklace
    # l = length of longest prefix that is a lyndon word
    if ($k > $n) {
        if(($n % $l) == 0) {
            for $k (1 .. $n) {
                push @{ $necklaces->[$$i] }, $parts->[$k];
            }
            $$i++;
        }
    }
    else {
        $parts->[$k] = $parts->[ $k - $l ];
        if ($parts->[$k] == 1) {
            _neckbin($n, $k + 1, $l, $i, $necklaces, $parts);
            $parts->[$k] = 0;
            _neckbin($n, $k + 1, $k, $i, $necklaces, $parts);
        }
        else {
            _neckbin($n, $k + 1, $l, $i, $necklaces, $parts);
        }
    }
}

=head2 necka

  $necklaces = $mcr->necka($n, @intervals);

Generate binary necklaces of length B<n> with allowed intervals
B<p1, p2, ... pn>.

=cut

sub necka {
    my ($self, $n, @intervals) = @_;
    my @necklaces;
    my @parts = (1);
    my $i = 0;
    _neckbina($n, 1, 1, 1, \$i, \@necklaces, \@parts, \@intervals);
    return \@necklaces;
}

sub _neckbina {
    my ($n, $k, $l, $p, $i, $necklaces, $parts, $intervals) = @_;
    if ($k > $n) {
      if (($n % $l) == 0 && _allowed($p, $intervals) && $p <= $n) {
        for $k (1 .. $n) {
          push @{ $necklaces->[$$i] }, $parts->[$k];
        }
        $$i++;
      }
    }
    else {
        $parts->[$k] = $parts->[ $k - $l ];
        if ($parts->[$k] == 1) {
            if (_allowed($p, $intervals) || $k == 1) {
              _neckbina($n, $k + 1, $l, 1, $i, $necklaces, $parts, $intervals);
            }
            $parts->[$k] = 0;
            _neckbina($n, $k + 1, $k, $p + 1, $i, $necklaces, $parts, $intervals);
        }
        else {
            _neckbina($n, $k + 1, $l, $p + 1, $i, $necklaces, $parts, $intervals);
        }
    }
}

=head2 neckam

  $necklaces = $mcr->neckam($n, $m, @intervals);

Generate binary necklaces of length B<n> with B<m> ones, and allowed
intervals B<p1, p2, ... pn>.

=cut

sub neckam {
    my ($self, $n, $m, @intervals) = @_;
    my @necklaces;
    my @parts = (1);
    my $i = 0;
    _neckbinam($n, 1, 1, 0, 1, $m, \$i, \@necklaces, \@parts, \@intervals);
    return \@necklaces;
}

sub _neckbinam {
    my ($n, $k, $l, $q, $p, $m, $i, $necklaces, $parts, $intervals) = @_;
    if ($k > $n) {
        if(($n % $l) == 0 && _allowed($p, $intervals) && $p <= $n && $q == $m) {
            for $k (1 .. $n) {
                push @{ $necklaces->[$$i] }, $parts->[$k];
            }
            $$i++;
        }
    }
    else {
        $parts->[$k] = $parts->[ $k - $l ];
        if ($parts->[$k] == 1) {
            if (_allowed($p, $intervals) || $k == 1) {
                _neckbinam($n, $k + 1, $l, $q + 1, 1, $m, $i, $necklaces, $parts, $intervals);
            }
            $parts->[$k] = 0;
            _neckbinam($n, $k + 1, $k, $q, $p + 1, $m, $i, $necklaces, $parts, $intervals);
        }
        else {
            _neckbinam($n, $k + 1, $l, $q, $p + 1, $m, $i, $necklaces, $parts, $intervals);
        }
    }
}

=head2 neckm

  $necklaces = $mcr->neckm($n, $m);

Generate all binary necklaces of length B<n> with B<m> ones.

=cut

sub neckm {
    my ($self, $n, $m) = @_;
    my @necklaces;
    my @parts = (1);
    my $i = 0;
    _neckbinm($n, 1, 1, 0, $m, \$i, \@necklaces, \@parts);
    return \@necklaces;
}

sub _neckbinm {
    my ($n, $k, $l, $p, $m, $i, $necklaces, $parts) = @_;
    # k = length of necklace
    # l = length of longest prefix that is a lyndon word
    # p = number of parts (ones)
    if ($k > $n) {
        if (($n % $l) == 0 && $p == $m) {
            for $k (1 .. $n) {
              push @{ $necklaces->[$$i] }, $parts->[$k];
            }
            $$i++;
        }
    }
    else {
        $parts->[$k] = $parts->[ $k - $l ];
        if ($parts->[$k] == 1) {
            _neckbinm($n, $k + 1, $l, $p + 1, $m, $i, $necklaces, $parts);
            $parts->[$k] = 0;
            _neckbinm($n, $k + 1, $k, $p, $m, $i, $necklaces, $parts);
        }
        else {
            _neckbinm($n, $k + 1, $l, $p, $m, $i, $necklaces, $parts);
        }
    }
}

=head2 part

  $partitions = $mcr->part($n);

Generate all partitions of B<n>.

=cut

sub part {
    my ($self, $n) = @_;
    my $i = Integer::Partition->new($n, { lexicographic => 1 });
    my @partitions;
    while (my $p = $i->next) {
        push @partitions, [ sort { $a <=> $b } @$p ];
    }
    return \@partitions;
}

=head2 parta

  $partitions = $mcr->parta($n, @intervals);

Generate all partitions of B<n> with allowed intervals
B<p1, p2, ... pn>.

=cut

sub parta {
    my ($self, $n, @parts) = @_;
    my $re = list2re @parts;
    my $i = Integer::Partition->new($n, { lexicographic => 1 });
    my @partitions;
    while (my $p = $i->next) {
      push @partitions, [ sort { $a <=> $b } @$p ]
        if all { $_ =~ /^$re$/ } @$p;
    }
    return \@partitions;
}

=head2 partam

  $partitions = $mcr->partam($n, $m, @intervals);

Generate all partitions of B<n> with B<m> parts from the intervals
B<p1, p2, ... pn>.

=cut

sub partam {
    my ($self, $n, $m, @parts) = @_;
    my $re = list2re @parts;
    my $i = Integer::Partition->new($n);
    my @partitions;
    while (my $p = $i->next) {
        push @partitions, [ sort { $a <=> $b } @$p ]
          if @$p == $m && all { $_ =~ /^$re$/ } @$p;
    }
    return \@partitions;
}

=head2 partm

  $partitions = $mcr->partm($n, $m);

Generate all partitions of B<n> into B<m> parts.

=cut

sub partm {
    my ($self, $n, $m) = @_;
    my $i = Integer::Partition->new($n);
    my @partitions;
    while (my $p = $i->next) {
        push @partitions, [ sort { $a <=> $b } @$p ]
          if @$p == $m;
    }
    return \@partitions;
}

=head2 permute

  $all_permutations = $mcr->permute(\@parts);

Return all permutations of the given B<parts> list as an
array-reference of array-references.

(For an efficient iterator, check out the L<Algorithm::Combinatorics>
module.)

=cut 

sub permute {
    my ($self, $parts) = @_;
    my @permutations = permutations($parts);
    return \@permutations;
}

=head2 reverse_at

  $sequence = $mcr->reverse_at($n, $parts);

Reverse a section of a B<parts> sequence at B<n>.

=cut

sub reverse_at {
    my ($self, $n, $parts) = @_;
    my @head = @$parts[ 0 .. $n - 1 ];
    my @tail = reverse @$parts[ $n .. $#$parts ];
    my @data = (@head, @tail);
    return \@data;
}

=head2 rotate_n

  $sequence = $mcr->rotate_n($n, $parts);

Rotate a necklace of the given B<parts>, B<n> times.

=cut

sub rotate_n {
    my ($self, $n, $parts) = @_;
    my $atu = Music::AtonalUtil->new;
    my $sequence = $atu->rotate($n, $parts);
    return $sequence;
}

sub _allowed { # is p one of the parts?
    my ($p, $parts) = @_;
    return any { $p == $_ } @$parts;
}

1;
__END__

=head1 SEE ALSO

L<https://abrazol.com/books/rhythm1/> "Creating Rhythms"

The F<t/01-methods.t> and F<eg/*> programs included with this distribution.

L<Algorithm::Combinatorics>

L<Data::Munge>

L<Integer::Partition>

L<List::Util>

L<Math::Sequence::DeBruijn>

L<Moo>

L<Music::AtonalUtil>

=cut
