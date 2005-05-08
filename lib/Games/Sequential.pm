package Games::Sequential;
use Carp;
use 5.006001;
use strict;
use warnings;

our $VERSION = '0.3.0';

=head1 NAME

Games::Sequential - sequential games framework with OO interface

=head1 SYNOPSIS

  package Games::Sequential::SomethingOrOther;
  use base Games::Sequential;

  sub apply { ... }

  my $game = Games::Sequential::SomethingOrOther->new($initialpos);
  $game->debug(1);

  $game->move($mv);
  $game->undo;


=head1 DESCRIPTION

Games::Sequential provides a simple base class for sequential
games. It provides an undo mechanism, as it keeps track of the
history of moves, in addition to methods to clone a game state
with or without history.

=head1 DOMAIN-SPECIFIC METHODS

Users must inherit from this module and implement an C<apply>
method particular to the game in question. This method takes care
of creating a new position by copying the current position and
applying the provided move to it. 

The method will probably look something along these lines (sans
error checking):

  sub apply {
    my ($self, $pos, $move) = @_;
    my $newpos = copy_pos($pos);

    ... apply $move to $newpos ...

    return $newpos;
  }


=head1 METHODS

Users must not modify the referred-to values of references
returned by any of the below methods.

=over 4

=item new $initialpos [@list]

Create and return a new AlphaBeta object. The first argument must
be the initial position of the game. The C<debug> option can also
be set here. 

=cut 

sub new {
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $self = bless {}, $class;

    $self->_init(@_) or carp "Failed to init object!";
    return $self;
}


=item _init [@list]

I<Internal method>

Initialize an AlphaBeta object.

=cut

sub _init {
    my $self = shift;
    my $pos = shift or croak "No initial position given!";
    my $args = @_ && ref($_[0]) ? shift : { @_ };

    my %config = (
        # Stacks for backtracking
        pos_hist    => [ $pos ],
        move_hist   => [],

        # Debug and statistics
        debug       => 0,
    );

    # Set defaults
    @$self{keys %config} = values %config;

    # Override defaults
    while (my ($key, $val) = each %{ $args }) {
        $self->{$key} = $val if exists $self->{$key};
    }

    croak "no apply() method defined" unless $self->can("apply");

    return $self;
}


=item debug [$value]

Return current debug level and, if invoked with an argument, set
to new value.

=cut

sub debug {
    my $self = shift;
    my $prev = $self->{debug};
    $self->{debug} = shift if @_;
    return $prev;
}


=item peek_pos

Return reference to current position.
Use this for drawing the board etc.

=cut

sub peek_pos {
    my $self = shift;
    return $self->{pos_hist}[-1];
}


=item peek_move

Return reference to last applied move.

=cut

sub peek_move {
    my $self = shift;
    return $self->{move_hist}[-1];
}


=item move $move

Apply $move to the current position, keeping track of history.
A reference to the new position is returned, or undef on failure.

=cut

sub move {
    my ($self, $move) = @_;
    my $pos = $self->peek_pos;

    my $npos = $self->apply($pos, $move)
        or croak "apply() failed";

    push @{ $self->{pos_hist} }, $npos;
    push @{ $self->{move_hist} }, $move;

    return $self->peek_pos;
}


=item undo

Undo last move. A reference to the previous position is returned,
or undef if there was no more moves to undo.

=cut

sub undo {
    my $self = shift;
    return unless pop @{ $self->{move_hist} };
    pop @{ $self->{pos_hist} } 
        or croak "move and pos stack out of sync!";
    return $self->peek_pos;
}


1;  # ensure using this module works
__END__

=back

=head1 TODO

Implement missing methods, e.g.: clone(), snapshot(), save()
E<amp> resume().


=head1 SEE ALSO

The author's website, describing this module and other projects:
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
