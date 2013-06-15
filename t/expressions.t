use strict;
use warnings;

use Test::More;
use lib 'lib';
use Mojolicious::Plugin::LiquidToMojo;

my $ltm = Mojolicious::Plugin::LiquidToMojo->new;
$ltm->testing;

is($ltm->liquid_to_mojo(qq~{{ 'simple text' }}~), qq~<%== 'simple text' %>\n~, 'simple text');
is($ltm->liquid_to_mojo(qq~{{ name }}~), qq~<%== \$name %>\n~, 'scalar');
is($ltm->liquid_to_mojo(qq~{{ hash.key }}~), qq~<%== \$hash->{key} %>\n~, 'hash reference');
is($ltm->liquid_to_mojo(qq~{{ hash.hash.key }}~), qq~<%== \$hash->{hash}{key} %>\n~, 'hash of hash');
is($ltm->liquid_to_mojo(qq~{{ array[0] }}~), qq~<%== \$array->[0] %>\n~, 'array reference');
is($ltm->liquid_to_mojo(qq~{{ array[0][1] }}~), qq~<%== \$array->[0][1] %>\n~, 'array of array');
is($ltm->liquid_to_mojo(qq~{{ [1, 2, 3] }}~), qq~<%== [1, 2, 3] %>\n~, 'anonymous array');
is($ltm->liquid_to_mojo(qq~{{ hash.array[0].hash.array[1].hash.key }}~), qq~<%== \$hash->{array}[0]{hash}{array}[1]{hash}{key} %>\n~, 'mixed');

done_testing();
