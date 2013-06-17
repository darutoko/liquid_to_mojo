use strict;
use warnings;
use feature ':5.14';

use Test::More;
use lib 'lib';
use Mojolicious::Plugin::LiquidToMojo;

my $ltm = Mojolicious::Plugin::LiquidToMojo->new;
$ltm->testing;

is($ltm->date_liquid_filter("%d-%m-%Y", '1371303105'), '15-06-2013', 'date_liquid_filter');
is($ltm->capitalize_liquid_filter('some simple text'), 'Some Simple Text', 'capitalize_liquid_filter');
is($ltm->size_liquid_filter('some simple text'), '16', 'size_liquid_filter with string');
is($ltm->size_liquid_filter([1, 2, 3, 7, 6, 5]), '6', 'size_liquid_filter with array reference');
is($ltm->escape_liquid_filter('<b>text</b>'), '&lt;b&gt;text&lt;/b&gt;', 'escape_liquid_filter');
is($ltm->strip_html_liquid_filter('<b>Hello</b> <i>world!</i>'), 'Hello world!', 'strip_html_liquid_filter');
is($ltm->plus_liquid_filter(4, 2), '6', 'plus_liquid_filter with numbers');
is($ltm->plus_liquid_filter('a', 'b'), 'ba', 'plus_liquid_filter with strings');
is($ltm->contains_liquid_filter(2, [1, 2, 3]), '1', 'contains_liquid_filter with array');
is($ltm->contains_liquid_filter('hello', 'hello world'), '1', 'contains_liquid_filter with string');

is($ltm->cycle_liquid_iterator( "'one', 'two', 'three'" ), qq~one~, 'cycle_liquid_iterator one');
is($ltm->cycle_liquid_iterator( "'one', 'two', 'three'" ), qq~two~, 'cycle_liquid_iterator two');
is($ltm->cycle_liquid_iterator( "'one', 'two', 'three'" ), qq~three~, 'cycle_liquid_iterator three');
is($ltm->cycle_liquid_iterator( "'one', 'two', 'three'" ), qq~one~, 'cycle_liquid_iterator one');
is($ltm->cycle_liquid_iterator( "'group 1': 'one', 'two', 'three'" ), qq~one~, 'cycle_liquid_iterator group 1: one');
is($ltm->cycle_liquid_iterator( "'group 2': 'one', 'two', 'three'" ), qq~one~, 'cycle_liquid_iterator group 2: one');
is($ltm->cycle_liquid_iterator( "'group 1': 'one', 'two', 'three'" ), qq~two~, 'cycle_liquid_iterator group 1: two');
is($ltm->cycle_liquid_iterator( "'group 2': 'one', 'two', 'three'" ), qq~two~, 'cycle_liquid_iterator group 2: two');

done_testing();
