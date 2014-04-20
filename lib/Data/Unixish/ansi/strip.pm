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
    tags => [qw/text ansi itemfunc/],
    "x.perinci.cmdline.default_format" => "text-simple",
};
sub strip {
    my %args = @_;
    my ($in, $out) = ($args{in}, $args{out});

    while (my ($index, $item) = each @$in) {
        push @$out, _strip_item($item);
    }

    [200, "OK"];
}

sub _strip_item {
    my $item = shift;
    {
        last if !defined($item) || ref($item);
        $item = ta_strip($item);
    }
    return $item;
}

1;
# ABSTRACT: Strip ANSI codes (colors, etc) from text

=head1 SYNOPSIS

In Perl:

 use Data::Unixish qw(lduxl);
 $stripped = lduxl('ansi::strip', "\e[1mblah"); # "blah"

In command line:

 % echo -e "\e[1mHELLO";                   # text will appear in bold
 % echo -e "\e[1mHELLO" | dux ansi::strip; # text will appear normal
 HELLO

=cut
