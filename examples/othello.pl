#!/usr/bin/perl
use warnings;
use strict;

use Games::AlphaBeta;
use Games::AlphaBeta::Reversi;

my ($p, $g);
$p = Games::AlphaBeta::Reversi->new;
$g = Games::AlphaBeta->new($p);

while ($p = $g->abmove) {
   print $p->as_string;
}


