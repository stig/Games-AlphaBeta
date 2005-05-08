package Games::AlphaBeta::Reversi;
use base Games::Sequential::Position;
use Carp;

use strict;
use warnings;

our $VERSION = '0.1';

=head1 NAME

Games::AlphaBeta::Reversi - class used with Games::AlphaBeta for
playing Reversi

=head1 SYNOPSIS

  package My::Reversi;
  use base Games::AlphaBeta::Reversi;

  # Override drawing routine
  sub draw { ... }

  package main;
  use My::Reversi;
  use Games::AlphaBeta;

  my ($p, $g);
  $p = My::Reversi->new;
  $g = Games::AlphaBeta->new($p);

  while ($g->abmove) {
    $p->draw;
  }

=head1 DESCRIPTION


=head1 METHODS

=over 4

=item _init()

I<Internal method.>

Initialize the initial state.

=cut

sub _init {
    my $self = shift;
    my $size = 8;
    my $half = abs($size / 2);
    my %config = (
        player => 1,
        size => $size,
        board => undef,
    );

    # Create a blank board
    $size--;
    for my $x (0 .. $size) {
        for my $y (0 .. $size) {
            $config{board}[$x][$y] = 0;
        }
    }

    # Put initial pieces on board
    $config{board}[$size - $half][$size - $half] = 1;
    $config{board}[$half][$half] = 1;
    $config{board}[$size - $half][$half] = 2;
    $config{board}[$half][$size - $half] = 2;

    @$self{keys %config} = values %config;

    $self->SUPER::_init(@_) or croak "failed to call SUPER:_init()";
    return $self;
}

=item as_string

Return a plain-text representation of the current game position
as a string.

=cut

sub as_string {
    my $self = shift;

    # Header
    my ($c, $str) = "a";
    $str .= " " . $c++ for (1 .. $self->{size});
    $str  = sprintf("    %s\n", $str);
    $str .= sprintf("   +%s\n", "--" x $self->{size});

    # Actual board (with numbers down the left side)
    my $i;
    for (@{$self->{board}}) {
        for (join " ", @$_) {
            s/0/./g;
            s/1/o/g;
            s/2/x/g;
            $str .= sprintf("%2d | %s\n", ++$i, $_);
        }
    }
    
    # Footer
    $str .= "Player " . $self->{player} . " to move.\n";
    return $str;
}
    
=item apply $move

Apply a move to the current position, producing the new position.

=cut

sub apply ($) {
    my ($self, $move) = @_;
    print "I'm here, don't worry...\n";
}

=back

=head1 BUGS


=head1 TODO


=head1 SEE ALSO

The author's website, describing this and other projects:
http://brautaset.org/projects/


=head1 AUTHOR

Stig Brautaset, E<lt>stig@brautaset.orgE<gt>

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2004 by Stig Brautaset

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.

=cut

# vim: shiftwidth=4 tabstop=4 softtabstop=4 expandtab 
