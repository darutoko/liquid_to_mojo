use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::LiquidToMojo',
  VERSION_FROM => 'lib/Mojolicious/Plugin/LiquidToMojo.pm',
  AUTHOR       => 'darutoko <darutoko@cpan.org>',
  INSTALLDIRS  => 'site',
  PREREQ_PM    => {
  	'HTML::Restrict' => 2.1.6,
  	'Mojolicious'    => '3.97',
  	'POSIX'          => 1.24,
  	'Scalar::Util'   => 1.23
  	'Test::More'     => 0,
  },
  test         => {TESTS => 't/*.t'}
);
