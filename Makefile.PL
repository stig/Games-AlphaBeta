use 5.006001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Games::AlphaBeta',
    VERSION           => '0.4.5',
    PREREQ_PM         => {Games::Sequential => '0.4.3', Carp => 0}, # any version will do
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Games/AlphaBeta.pm', # retrieve abstract from module
       AUTHOR         => 'Stig Brautaset <stig@brautaset.org>') : ()),
);
