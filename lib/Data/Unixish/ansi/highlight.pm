package Data::Unixish::ansi::highlight;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use Term::ANSIColor;
use Text::ANSI::Util qw(ta_highlight_all);

# VERSION

our %SPEC;

$SPEC{highlight} = {
    v => 1.1,
    summary => 'Highlight string/pattern with color',
    args => {
        %common_args,
        string => {
            summary => 'String to search',
            schema  => 'str*',
            cmdline_aliases => { s=>{} },
            description => <<'_',

Either this or `pattern` is required.

_
        },
        pattern => {
            summary => 'Regex pattern to search',
            schema  => ['str*', is_re=>1],
            cmdline_aliases => { p=>{} },
            description => <<'_',

Either this or `string` is required.

_
        },
        ci => {
            summary => 'Whether to search case-insensitively',
            schema  => ['bool', default=>0],
        },
        color => {
            summary => 'The color to use for each item',
            schema => ['str*', default => 'bold red'],
            description => <<'_',

Example: `red`, `bold blue`, `yellow on_magenta`, `black on_bright_yellow`. See
Perl module Term::ANSIColor for more details.

You can also supply raw ANSI code.

_
        },
    },
    tags => [qw/text ansi/],
    "x.dux.default_format" => "text-simple",
};
sub highlight {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    my $ci = $args{ci};
    my $color = $args{color} // 'bold red';
    $color = color($color) unless $color =~ /\A\e/;

    my $re;
    if (defined($args{string})) {
        $re = $ci ? qr/\Q$args{string}\E/io : qr/\Q$args{string}\E/o;
    } elsif (defined($args{pattern})) {
        $re = $ci ? qr/$args{pattern}/io : qr/$args{pattern}/o;
    } else {
        return [400, "Please specify 'string' or 'pattern'"];
    }

    while (my ($index, $item) = each @$in) {
        {
            last if !defined($item) || ref($item);
            $item = ta_highlight_all($item, $re, $color);
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Highlight string/pattern with color

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 $hilited = lduxl(['ansi::highlight' => {string=>"er"}], "merah"); # "m\e[31m\e[1mer\e[0mah"

In command line:

 % echo -e "merah" | dux ansi::highlight -s er; # 'er' will be highlighted
 merah

=cut
