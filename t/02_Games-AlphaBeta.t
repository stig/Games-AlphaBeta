# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Games-GGTL.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

package Games::AlphaBeta::Test;
use Test::More tests => 14;
BEGIN { 
  use base Games::AlphaBeta;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

sub apply {
    my ($self, $p, $m) = @_;

    $m = -$m if $p->{player} == 2;
    my $np = {
        player => 3 - $p->{player},
        val => $p->{val} + $m,
    };
    return $np;
}

sub endpos {
    my ($self, $p) = @_;
    return $p->{val} > 30 ? 1 : 0;
}

sub evaluate {
    my ($self, $p) = @_;
    return $p->{val};
}

sub findmoves {
    return (0, 1, -1, 0);
}

my $p = {
        player => 1,
        val => 0
};

my $g;
ok($g = Games::AlphaBeta::Test->new($p),  "new(\$pos)");
isa_ok($g, Games::AlphaBeta);
isa_ok($g, Games::Sequential);

can_ok($g, qw/apply endpos evaluate findmoves abmove ply/);

ok($g->abmove(4),       "abmove(4)");
ok($p = $g->peek_pos,   "peek_pos()");
is($g->peek_move, 1,    "peek_move()");
is($p->{player}, 2,     "check player turn");
is($p->{val}, 1,        "check best value");

is($g->ply(3), 2,       "set & read ply");
ok($g->abmove,          "abmove()");

is($p->{player}, 2,     "check player turn");
is($p->{val}, 1,        "current value");
is($g->peek_move, 1,    "peek_move()");

