use 5.006001;
use lib 'mbk';
use Module::Build::Kwalitee;

Module::Build::Kwalitee->new(
  module_name => 'Games::AlphaBeta',
  license => 'perl',
  build_requires => {
    'Test::More' => 0,
    'File::Spec::Functions' => 0,
  },
  script_files => qw(
    bin/othello-demo
  ),
  create_readme => 1,
  create_makefile_pl => 'passthrough',
)->create_build_script;
