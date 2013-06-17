use strict;
use warnings;

use Test::More;
use lib 'lib';
use Mojolicious::Plugin::LiquidToMojo;

my $ltm = Mojolicious::Plugin::LiquidToMojo->new;
$ltm->testing;

is($ltm->liquid_to_mojo(qq~{{ 'now' | date: "%Y %h:%M" }}~), qq~<%== date_liquid_filter( "%Y %h:%M", 'now' ) %>\n~, 'date');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | capitalize }}~), qq~<%== capitalize_liquid_filter( 'some text' ) %>\n~, 'capitalize');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | downcase }}~), qq~<%== lc( 'some text' ) %>\n~, 'downcase');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | upcase }}~), qq~<%== uc( 'some text' ) %>\n~, 'upcase');
is($ltm->liquid_to_mojo(qq~{{ array | first }}~), qq~<%== \$array->[0] %>\n~, 'first');
is($ltm->liquid_to_mojo(qq~{{ my.array | last }}~), qq~<%== \$my->{array}[-1] %>\n~, 'last');
is($ltm->liquid_to_mojo(qq~{{ array | join: ', ' }}~), qq~<%== join(', ', \@{ \$array }) %>\n~, 'join');
is($ltm->liquid_to_mojo(qq~{{ [1, 2, 3] | sort }}~), qq~<%== [ sort(\@{ [1, 2, 3] }) ] %>\n~, 'sort');
is($ltm->liquid_to_mojo(qq~{{ array | size }}~), qq~<%== size_liquid_filter( \$array ) %>\n~, 'size');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | escape }}~), qq~<%== escape_liquid_filter( 'some text' ) %>\n~, 'escape');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | strip_html }}~), qq~<%== strip_html_liquid_filter( 'some text' ) %>\n~, 'strip_html');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | strip_newlines }}~), qq~<%== 'some text' =\~ s/\\n//gr %>\n~, 'strip_newlines');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | newline_to_br }}~), qq~<%== 'some text' =\~ s/\\n/<br>/gr %>\n~, 'newline_to_br');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | replace: 'from','to' }}~), qq~<%== 'some text' =\~ s/from/to/rg %>\n~, 'replace');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | replace_first: 'from','to' }}~), qq~<%== 'some text' =\~ s/from/to/r %>\n~, 'replace_first');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | remove: 'from' }}~), qq~<%== 'some text' =\~ s/from//rg %>\n~, 'remove');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | remove_first: 'from', }}~), qq~<%== 'some text' =\~ s/from//r %>\n~, 'remove_first');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | truncate:5 }}~), qq~<%== substr( 'some text', 0, 5 ) %>\n~, 'truncate');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | truncatewords:5 }}~), qq~<%== join(' ', ( split(/\\s+/, 'some text') )[0..5] ) %>\n~, 'truncatewords');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | prepend:'little ' }}~), qq~<%== 'little '.'some text' %>\n~, 'prepend');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | append:' here' }}~), qq~<%== 'some text'.' here' %>\n~, 'append');
is($ltm->liquid_to_mojo(qq~{{ 4 | minus:2 }}~), qq~<%== 4 - 2 %>\n~, 'minus');
is($ltm->liquid_to_mojo(qq~{{ 4 | plus:2 }}~), qq~<%== plus_liquid_filter( 2, 4 ) %>\n~, 'plus');
is($ltm->liquid_to_mojo(qq~{{ 4 | times:2 }}~), qq~<%== 4 * 2 %>\n~, 'times');
is($ltm->liquid_to_mojo(qq~{{ 4 | divided_by:2 }}~), qq~<%== 4 / 2 %>\n~, 'divided_by');
is($ltm->liquid_to_mojo(qq~{{ 4 | modulo:2 }}~), qq~<%== 4 % 2 %>\n~, 'modulo');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | split:, }}~), qq~<%== split( /,/, 'some text' ) %>\n~, 'split');
is($ltm->liquid_to_mojo(qq~{{ 'some text' | split:', ' }}~), qq~<%== split( /, /, 'some text' ) %>\n~, 'split with commas');
is($ltm->liquid_to_mojo(qq~{{ array | contains:5 }}~), qq~<%== contains_liquid_filter( 5, \$array ) %>\n~, 'contains');

TODO: {
	local $TODO = q~Don't know how it should be used or behaved~;
	is($ltm->liquid_to_mojo(qq~{{ array | map }}~), qq~<%== map %>\n~, 'map');
	is($ltm->liquid_to_mojo(qq~{{ 'some text' | escape_once }}~), qq~<%== escape_once_liquid_filter(  ) %>\n~, 'escape_once');
}

done_testing();
