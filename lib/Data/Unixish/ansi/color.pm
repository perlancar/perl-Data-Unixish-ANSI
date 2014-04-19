package Data::Unixish::ansi::color;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
use Log::Any '$log';

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
            pos => 0,
        },
    },
    tags => [qw/text ansi itemfunc/],
    "x.dux.default_format" => "text-simple",
};
sub color {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    _color_begin(\%args);
    while (my ($index, $item) = each @$in) {
        push @$out, _color_item($item, \%args);
    }

    [200, "OK"];
}

sub _color_begin {
    my $args = shift;

    # abuse args to store state
    my $color = $args->{color};
    $color = Term::ANSIColor::color($color) unless $color =~ /\A\e/;
    $args->{_color} = $color;
}

sub _color_item {
    my ($item, $args) = @_;

    {
        last if !defined($item) || ref($item);
        $item = $args->{_color} . $item . "\e[0m";
        #$log->tracef("item=%s, color=%s", $item, $args->{_color});
    }
    return $item;
}

1;
# ABSTRACT: Colorize text with ANSI color codes

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 $colorized = lduxl(['ansi::color' => {color=>"red"}], "red"); # "\e[31mred\e[0m"

In command line:

 % echo -e "HELLO" | dux ansi::color --color red; # text will appear in red
 HELLO

=cut
