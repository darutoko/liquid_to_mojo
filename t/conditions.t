use strict;
use warnings;
use feature ':5.14';

use Test::More;
use lib 'lib';
use Mojolicious::Plugin::LiquidToMojo;

my $ltm = Mojolicious::Plugin::LiquidToMojo->new;
$ltm->testing;

is($ltm->liquid_to_mojo(qq~{% if user %}~), qq~<% if( \$user ){ %>\n~, 'simple variable');
is($ltm->liquid_to_mojo(qq~{% if user.name == 'tobi' %}~), qq~<% if( \$user->{name} eq 'tobi' ){ %>\n~, 'variable EQ string');
is($ltm->liquid_to_mojo(qq~{% if user.name != 'tobi' %}~), qq~<% if( \$user->{name} ne 'tobi' ){ %>\n~, 'variable NE string');
is($ltm->liquid_to_mojo(qq~{% if user.name == 'tobi' or user.name == 'bob' %}~), qq~<% if( \$user->{name} eq 'tobi' or \$user->{name} eq 'bob' ){ %>\n~, 'variable eq string OR string');
is($ltm->liquid_to_mojo(qq~{% if user.name == 'bob' and user.age > 45 %}~), qq~<% if( \$user->{name} eq 'bob' and \$user->{age} > 45 ){ %>\n~, 'variable eq string AND more than number');
is($ltm->liquid_to_mojo(qq~{% if user.payments == empty %}~), qq~<% if( !\@{ \$user->{payments} } ){ %>\n~, 'array is empty');
is($ltm->liquid_to_mojo(qq~{% if user.payments != empty %}~), qq~<% if( \@{ \$user->{payments} } ){ %>\n~, 'array is not empty');
is($ltm->liquid_to_mojo(qq~{% if array contains 2 %}~), qq~<% if( contains_liquid_filter( 2, \$array ) ){ %>\n~, 'array contains variable');
is($ltm->liquid_to_mojo(qq~{% unless user.name == 'tobi' %}~), qq~<% unless( \$user->{name} eq 'tobi' ){ %>\n~, 'test unless');
is($ltm->liquid_to_mojo(qq~{% elsif user.name == 'tobi' %}~), qq~<% }elsif( \$user->{name} eq 'tobi' ){ %>\n~, 'test elsif');
is($ltm->liquid_to_mojo(qq~{% endif %}~), qq~<% } %>\n~, 'test endif');
is($ltm->liquid_to_mojo(qq~{% endunless %}~), qq~<% } %>\n~, 'test endunless');
is($ltm->liquid_to_mojo(qq~
{% case condition %}
{% when 'baz' %}
{% when 2 or 3 %}
{% when 'foo' and 'bar' %}
{% else %}
{% endcase %}
~), qq~
<%  %>
<% if( \$condition eq 'baz' ){ %>
<% }elsif( \$condition == 2 or \$condition == 3 ){ %>
<% }elsif( \$condition eq 'foo' and \$condition eq 'bar' ){ %>
<% }else{ %>
<% } %>
~, 'test case');

done_testing();
