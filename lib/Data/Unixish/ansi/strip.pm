package Data::Unixish::ansi::strip;

use 5.010;
use strict;
use syntax 'each_on_array'; # to support perl < 5.12
use warnings;
#use Log::Any '$log';

use Data::Unixish::Util qw(%common_args);
use Text::ANSI::Util qw(ta_strip);

# VERSION

our %SPEC;

$SPEC{strip} = {
    v => 1.1,
    summary => 'Strip ANSI codes (colors, etc) from text',
    args => {
        %common_args,
    },
    tags => [qw/text ansi/],
    "x.dux.default_format" => "text-simple",
};
sub strip {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        {
            last if !defined($item) || ref($item);
            $item = ta_strip($item);
        }
        push @$out, $item;
    }

    [200, "OK"];
}

1;
# ABSTRACT: Strip ANSI codes (colors, etc) from text

=head1 SYNOPSIS

In Perl:

 use Data::Unixish::List qw(dux);
 $stripped = dux('ansi::strip', "\e[1mblah"); # "blah"

In command line:

 % echo -e "\e[1mHELLO";                   # text will appear in bold
 % echo -e "\e[1mHELLO" | dux ansi::strip; # text will appear normal
 HELLO

=cut

