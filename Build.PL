use 5.006001;
use lib 'mbk';
use Module::Build::Kwalitee;

Module::Build::Kwalitee->new(
  dist_name => 'Games::AlphaBeta',
  dist_version => '0.4.3',
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
