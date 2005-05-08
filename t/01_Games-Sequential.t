# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl
# Games-Sequential.t'

#########################

package Games::Sequential::Test;
use Test::More tests => 15;
BEGIN { 
  use base Games::Sequential;
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

sub apply {
    my ($self, $p, $m) = @_;
    return $p + $m;
}

my $g;

ok($g = Games::Sequential::Test->new(1), 'new(1)');
isa_ok($g, Games::Sequential);

can_ok($g, qw/new move undo peek_pos peek_move debug/);

is($g->peek_pos, 1,       "peek_pos()");
is($g->peek_move, undef,  "peek_move()");

is($g->debug(1), 0,       "debug(1)");
is($g->debug(0), 1,       "debug(0)");
is($g->debug, 0,          "debug()");
                       
is($g->move(1), 2,        "move(1)");
is($g->move(2), 4,        "move(2)");
                       
is($g->peek_pos, 4,       "peek_pos()");
is($g->peek_move, 2,      "peek_move()");
                       
is($g->move(1), 5,        "move(1)");
is($g->move(1), 6,        "move(1)");
is($g->undo, 5,           "undo()");
