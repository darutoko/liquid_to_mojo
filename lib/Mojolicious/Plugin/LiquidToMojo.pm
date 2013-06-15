package Mojolicious::Plugin::LiquidToMojo;
use Mojo::Base 'Mojolicious::Plugin';
use POSIX qw|strftime|;
use Mojo::Util qw|xml_escape|;
use HTML::Restrict;

our $VERSION = '0.01';

my $plugin;

has code => '';

has capture_start     => 'capture';
has capture_end       => 'endcapture';
has expression_start  => '{{';
has expression_end    => '}}';
has tag_start         => '{%';
has tag_end           => '%}';
has tree              => sub { [] };

sub testing { $plugin = shift }
sub register {
	my ($self, $app) = @_;

	$plugin = $self;
	$app->helper(liquid_to_mojo => \&liquid_to_mojo);
	$app->helper(date_liquid_filter => \&date_liquid_filter);
	$app->helper(plus_liquid_filter => \&plus_liquid_filter);
	$app->helper(size_liquid_filter => \&size_liquid_filter);
	$app->helper(escape_liquid_filter => \&escape_liquid_filter);
	$app->helper(capitalize_liquid_filter => \&capitalize_liquid_filter);
	$app->helper(strip_html_liquid_filter => \&strip_html_liquid_filter);
}

sub liquid_to_mojo {
	$plugin->parse($_[1])->build;

	return $plugin->code;
}

sub parse {
	my ($self, $template) = @_;
	
	my $tree = $self->tree;

	my $cpst      = $self->capture_start;
	my $cpen      = $self->capture_end;
	my $exp_start = $self->expression_start;
	my $exp_end   = $self->expression_end;
	my $tag_start = $self->tag_start;
	my $tag_end   = $self->tag_end;

	my $token_re = qr/
		(
			\Q$tag_start\E\s*\Q$cpst\E
		|
			\Q$tag_start\E
		|
			\Q$cpen\E\s*\Q$tag_end\E
		|
			\Q$tag_end\E
		|
			\Q$exp_start\E
		|
			\Q$exp_end\E
		)
	/x;
	my $end_re = qr/^(:?\Q$tag_end\E|\Q$exp_end\E)$/;

	# Split lines
	my $state = 'text';
	my @capture_token;
	for my $line (split /\n/, $template){
		# Escaped line ending
		$line .= "\n" unless $line =~ s/\\\\$/\\\n/ || $line =~ s/\\$//;

		# Mixed line
		my @token;
		for my $token (split $token_re, $line){
			# End
			if($state ne 'text' && $token =~ $end_re){
				$state = 'text';

				# Hint at end
				push @token, 'text', '';
			}
			# Code
			elsif($token =~ /^\Q$tag_start\E$/) { $state = 'code' }
			# Expression
			elsif($token =~ /^\Q$exp_start\E$/) { $state = 'expr' }
			# Text
			else{
				push @token, @capture_token, $state, $token;
				@capture_token = ();
			}
		}

		push @$tree, \@token;
	}

	return $self;
}

sub build {
	my $self = shift;
	
	my @lines;
	for my $line (@{$self->tree}){
		push @lines, '';
		for(my $i = 0; $i < @{$line}; $i += 2){
			my $type    = $line->[$i];
			my $value   = $line->[$i + 1] || '';
			my $newline = chomp $value;

			# Text
			if($type eq 'text'){
				$value     .= "\n" if $newline;
				$lines[-1] .= $value if length $value;
				next;
			}

			$self->_trim($value);

			# Code
			if($type eq 'code'){
				$lines[-1] .= '<% '. $value .' %>';
			}

			# Expression
			if($type eq 'expr'){
				$lines[-1] .= '<%== '. $self->_build_expression($self->_parse_expression($value)) .' %>';
			}
		}
	}

	return $self->code($self->_wrap(\@lines))->tree([]);
}

sub _parse_expression {
	my ($self, $expression) = @_;
	
	my @expression = split /\s*\|\s*/, $expression;

	return \@expression;
}

sub _build_expression {
	my ($self, $filters) = @_;
	my $token = pop $filters;

	return $self->_build_value($self->_parse_value($token)) unless scalar @$filters;

	my $filter     = $self->_parse_filter($token);
	my $expression = $self->_build_expression($filters);

	$expression .= '->' if $token =~ /^(?:first|last)/ && ($expression !~ /^\$/ || $expression !~ /\->/);

	$filter =~ s/{{expression}}/$expression/;

	return $filter;
}

sub _parse_value {
	my ($self, $token) = @_;
	
	my @value = split /\./, $token || '';

	return \@value;
}

sub _build_value {
	my ($self, $value) = @_;
	
	$value->[0] = '' unless defined $value->[0];
	return $value->[0] if $value->[0] =~ /^['"\[\(]/ or $value->[0] =~ /^$/ or $value->[0] =~ /^[\d\.]+$/;

	my $first = '$'. shift $value;
	$first =~ s/(?<=[\w_])(\[\d+\])/->$1/;

	if(scalar @$value){
		s/^([\w_]+)/{$1}/ for @$value;
		$value->[0] = '->'. $value->[0];
	}

	return join '', $first, @$value;
}

sub _parse_filter {
	my ($self, $token) = @_;
	
	# my @filter = $token =~ /^([\w_]+)(?:\:\s*(.+))?$/;
	my ($filter, $options) = split /:\s*/, $token, 2;

	return $self->_build_filter($filter, $options);
}

sub _build_filter {
	my ($self, $filter, $options) = @_;
	
	$_ = '_'. $filter;
	return $self->$_($options) if $self->can($_);
	die "Uknown filter '$filter'";
}

sub _trim {
	map {s/^\s+//;s/\s+$//;$_} $_[1];
}

sub _wrap {
	my ($self, $lines) = @_;
	
	my $code = join "\n", @$lines;

	return $code;
}


sub date_liquid_filter {
	my ($self, $format, $input) = @_;
	
	$input = time if lc $input eq 'now';

	return strftime $format, localtime($input);
}
sub capitalize_liquid_filter { $_[1] =~ s/\b(.*?)\b/$1 eq uc $1 ? $1 : "\u\L$1"/ger }
sub size_liquid_filter {
	my ($self, $input) = @_;

	return length $input unless ref $input;
	return scalar %{$input} if ref $input eq 'HASH';
	return scalar @{$input} if ref $input eq 'ARRAY';
	return 0;
}
sub escape_liquid_filter { return xml_escape $_[1] }
sub escape_once_liquid_filter {
	my ($self, $input) = @_;

	return;
}
sub plus_liquid_filter {
	my ($self, $value, $input) = @_;
	return $input . $value if $input ^ $input && $value ^ $value;
	return $input + $value;
}
sub strip_html_liquid_filter { return HTML::Restrict->new()->process($_[1]) }

sub _simple_filter {
	my ($self, $filter, $options) = @_;
	return $filter .'( {{expression}} )' unless $options;
	return $filter .'( '. $options .', {{expression}} )';
}
sub _date { shift->_simple_filter('date_liquid_filter', shift) }
sub _capitalize { shift->_simple_filter('capitalize_liquid_filter') }
sub _downcase { shift->_simple_filter('lc') }
sub _upcase { shift->_simple_filter('uc') }
sub _first {
	my ($self, $index) = @_;
	my $filter = '{{expression}}';
	$index = 0 unless $index || 1 == -1;

	# $filter .= '->' if $filter !~ /^\$/ || $filter !~ /\->/;
	return $filter .'['. $index .']';
}
sub _last { shift->_first(-1) }
sub _join { q|join(', ', @{ {{expression}} })| }
sub _sort { '[ sort(@{ {{expression}} }) ]' }
sub _map  { '[ map('. join(', ', $_[1], '@{ {{expression}} }') .') ]' }
sub _size { shift->_simple_filter('size_liquid_filter') }
sub _escape { shift->_simple_filter('escape_liquid_filter') }
sub _escape_once { shift->_simple_filter('escape_once_liquid_filter') }
sub _strip_html { shift->_simple_filter('strip_html_liquid_filter') }
sub _strip_newlines { '{{expression}} =~ s/\n//gr' }
sub _newline_to_br { '{{expression}} =~ s/\n/<br>/gr' }
sub _replace_first {
	my ($self, $options, $flag) = @_;
	my ($from, $to) = $options =~ /['"]([^'"]+)['"]/g;
	$flag ||= '';$to //= '';
	return "{{expression}} =~ s/$from/$to/r$flag";
}
sub _replace { shift->_replace_first(shift, 'g') }
sub _remove { shift->_replace_first(shift, 'g') }
sub _remove_first { shift->_replace_first(shift) }
sub _truncate {
	my ($self, $options) = @_;
	my ($length) = $options =~ /(\d+)/;
	return '{{expression}}' unless defined $length;
	return "substr( {{expression}}, 0, $length )";
}
sub _truncatewords {
	my ($self, $options) = @_;
	my ($length) = $options =~ /(\d+)/;
	return '{{expression}}' unless defined $length;
	return "join(' ', ( split(/\\s+/, {{expression}}) )[0..$length] )";
}
sub _prepend {
	my ($self, $options) = @_;
	$options = $self->_build_value($self->_parse_value($options));
	return $options .'.{{expression}}';
}
sub _append {
	my ($self, $options) = @_;
	$options = $self->_build_value($self->_parse_value($options));
	return '{{expression}}.'. $options;
}
sub _math {
	my ($self, $options, $operation) = @_;
	my ($num) = $options =~ /(\d+)/;
	return '{{expression}}' unless defined $num && defined $operation;
	return "{{expression}} $operation $num";
}
sub _minus { shift->_math(shift, '-') }
sub _times { shift->_math(shift, '*') }
sub _divided_by { shift->_math(shift, '/') }
sub _modulo { shift->_math(shift, '%') }
sub _plus { shift->_simple_filter('plus_liquid_filter', shift) }
sub _split {
	my ($self, $options) = @_;
	$options = $1 if $options =~ /^['"](.+)['"]$/;
	return "split( /$options/, {{expression}} )";
}
1;
__END__

=head1 NAME

Mojolicious::Plugin::LiquidToMojo - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('LiquidToMojo');

  # Mojolicious::Lite
  plugin 'LiquidToMojo';

=head1 DESCRIPTION

L<Mojolicious::Plugin::LiquidToMojo> is a L<Mojolicious> plugin.

=head1 METHODS

L<Mojolicious::Plugin::LiquidToMojo> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
