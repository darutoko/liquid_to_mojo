use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::LiquidToMojo',
  VERSION_FROM => 'lib/Mojolicious/Plugin/LiquidToMojo.pm',
  AUTHOR       => 'A Good Programmer <nospam@cpan.org>',
  PREREQ_PM    => {'Mojolicious' => '3.97'},
  test         => {TESTS => 't/*.t'}
);
