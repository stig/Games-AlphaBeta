use 5.006001;
use lib 'mbk';
use Module::Build::Kwalitee;

Module::Build::Kwalitee->new(
  module_name => 'Games::AlphaBeta',
  create_readme => 1,
  create_makefile_pl => 'passthrough',
  script_files => qw(
    bin/othello-demo
  ),
)->create_build_script;
