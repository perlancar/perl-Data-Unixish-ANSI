package Data::Unixish::ansi::color;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use Term::ANSIColor qw();

# VERSION

our %SPEC;

$SPEC{color} = {
    v => 1.1,
    summary => 'Colorize text with ANSI color codes',
    args => {
        %common_args,
        color => {
            schema => 'str*',
            summary => 'The color to use for each item',
            description => <<'_',

Example: `red`, `bold blue`, `yellow on_magenta`, `black on_bright_yellow`. See
Perl module Term::ANSIColor for more details.

You can also supply raw ANSI code.

_
            req => 1,
        },
    },
    tags => [qw/text ansi/],
    "x.dux.default_format" => "text-simple",
};
sub color {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my $color = $args{color};
    $color = Term::ANSIColor::color($color) unless $color =~ /\A\e/;

    while (my ($index, $item) = each @$in) {
        {
            last if !defined($item) || ref($item);
            $item = $color . $item . "\e[0m";
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Colorize text with ANSI color codes

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 $colorized = dux(['color' => {color=>"red"}], "red"); # "\e[31mred\e[0m"

In command line:

 % echo -e "HELLO" | dux ansi::color --color red; # text will appear in red
 HELLO

=cut

