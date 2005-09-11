use 5.006001;
use lib 'mbk';
use Module::Build::Kwalitee;

Module::Build::Kwalitee->new(
  module_name => 'Games::AlphaBeta',
  requires => {
    'Games::Sequential' => '0.4.3',
  },
  create_readme => 1,
  create_makefile_pl => 'passthrough',
)->create_build_script;
