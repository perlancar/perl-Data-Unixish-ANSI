package Data::Unixish::ANSI::highlight;

# DATE
# VERSION

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any::IfLOG '$log';

use Data::Unixish::Util qw(%common_args);
use Term::ANSIColor;
use Text::ANSI::Util qw(ta_highlight_all);

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
            pos => 0,
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
            cmdline_aliases => { i=>{} },
        },
        color => {
            summary => 'The color to use for each item',
            schema => ['str*', default => 'bold red'],
            description => <<'_',

Example: `red`, `bold blue`, `yellow on_magenta`, `black on_bright_yellow`. See
Perl module Term::ANSIColor for more details.

You can also supply raw ANSI code.

_
            cmdline_aliases => { c=>{} },
        },
    },
    tags => [qw/text ansi itemfunc/],
};
sub highlight {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    return [400, "Please specify string or pattern"]
        unless defined($args{pattern}) || defined($args{string});

    _highlight_begin(\%args);
    while (my ($index, $item) = each @$in) {
        push @$out, _highlight_item($item, \%args);
    }

    [200, "OK"];
}

sub _highlight_begin {
    my $args = shift;

    # abuse args to store state
    my $color = $args->{color} // 'bold red';
    $color = color($color) unless $color =~ /\A\e/;
    $args->{_color} = $color;

    my $re;
    if (defined($args->{string})) {
        $re = $args->{ci} ?
            qr/\Q$args->{string}\E/io : qr/\Q$args->{string}\E/o;
    } elsif (defined($args->{pattern})) {
        $re = $args->{ci} ?
            qr/$args->{pattern}/io : qr/$args->{pattern}/o;
    } else {
        die "Please specify 'string' or 'pattern'";
    }
    $args->{_re} = $re;
}

sub _highlight_item {
    my ($item, $args) = @_;

    {
        last if !defined($item) || ref($item);
        $item = ta_highlight_all($item, $args->{_re}, $args->{_color});
    }
    return $item;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 $hilited = lduxl(['ANSI::highlight' => {string=>"er"}], "merah"); # "m\e[31m\e[1mer\e[0mah"

In command line:

 % echo -e "merah" | dux ANSI::highlight -s er; # 'er' will be highlighted
 merah

=cut
