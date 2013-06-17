use strict;
use warnings;
use feature ':5.14';

use Test::More;
use lib 'lib';
use Mojolicious::Plugin::LiquidToMojo;

my $ltm = Mojolicious::Plugin::LiquidToMojo->new;
$ltm->testing;

is($ltm->liquid_to_mojo(qq~{% cycle 'one', 'two', 'three' %}~), qq~<%  %><%== cycle_liquid_iterator( "'one', 'two', 'three'" ) %><%  %>\n~, 'cycle_liquid_iterator');

is($ltm->liquid_to_mojo(qq~
{% for item in array %}
	{{ item }}
	{{ forloop.length }}
	{{ forloop.index }}
	{{ forloop.index0 }}
	{{ forloop.rindex }}
	{{ forloop.rindex0 }}
	{{ forloop.first }}
	{{ forloop.last }}
{% endfor %}
~), qq~
<% { my \@_liquid_array = \@{ \$array }; for( my \$_liquid_index = 0; \$_liquid_index <= \$#_liquid_array; \$_liquid_index++ ){ my \$item = \$_liquid_array[\$_liquid_index]; %>
	<%== \$item %>
	<%== scalar(\@_liquid_array) %>
	<%== \$_liquid_index + 1 %>
	<%== \$_liquid_index %>
	<%== scalar(\@_liquid_array) - \$_liquid_index - 1 %>
	<%== \$#_liquid_array - \$_liquid_index %>
	<%== \$_liquid_index == 0 %>
	<%== \$_liquid_index == \$#_liquid_array %>
<% } } %>
~, 'simple for loop');

is($ltm->liquid_to_mojo(
qq~{% for item in array limit:2 %}~),
qq~<% { my \@_liquid_array = \@{ \$array }; \@_liquid_array = \@_liquid_array[ 0 .. 0 + (2 - 1) ]; for( my \$_liquid_index = 0; \$_liquid_index <= \$#_liquid_array; \$_liquid_index++ ){ my \$item = \$_liquid_array[\$_liquid_index]; %>\n~
, 'for loop with limit');

is($ltm->liquid_to_mojo(
qq~{% for item in array limit:2 offset:3 reversed %}~),
qq~<% { my \@_liquid_array = \@{ \$array }; \@_liquid_array = \@_liquid_array[ 3 .. 3 + (2 - 1) ]; \@_liquid_array = reverse( \@_liquid_array ); for( my \$_liquid_index = 0; \$_liquid_index <= \$#_liquid_array; \$_liquid_index++ ){ my \$item = \$_liquid_array[\$_liquid_index]; %>\n~
, 'for loop with limit, offset and reversed');

is($ltm->liquid_to_mojo(
qq~{% for item in (1..item.quantity) %}~),
qq~<% { my \@_liquid_array = ( 1..\$item->{quantity} ); for( my \$_liquid_index = 0; \$_liquid_index <= \$#_liquid_array; \$_liquid_index++ ){ my \$item = \$_liquid_array[\$_liquid_index]; %>\n~
, 'for loop with range');

done_testing();
