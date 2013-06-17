use strict;
use warnings;
use feature ':5.14';

use Test::More;
use lib 'lib';
use Mojolicious::Plugin::LiquidToMojo;

my $ltm = Mojolicious::Plugin::LiquidToMojo->new;
$ltm->testing;

is($ltm->liquid_to_mojo(qq~{% assign name = 'freestyle' %}~), qq~<% my \$name = 'freestyle' %>\n~, 'assign');
is($ltm->liquid_to_mojo(qq~{% capture color %}my-color{% endcapture %}~), qq~<% my \$color = begin %>my-color<% end %>\n~, 'capture');
# is($ltm->liquid_to_mojo(qq~{%  %}~), qq~<% %>\n~, '');

done_testing();
