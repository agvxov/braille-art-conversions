#!/usr/bin/perl

# XXX: given-when is deprecated, but match is not yet implemented
use 5.10.0;
no warnings;

use utf8;
binmode(STDIN,  ":utf8");
binmode(STDOUT, ":utf8");

use Encode 'decode';

sub usage {
    print <<"END_USAGE";
$0 <verb>
    table  - print braille/inverted/flipped table
    invert - perform inversion on stdin
    flip   - perform mirroring on stdin (both line and character wise)
END_USAGE
}

sub invert {
    my ($string) = @_;
    sub invert_char {
        my ($char) = @_;
        my $codepoint = ord($char);
        
        return $char if $codepoint < 0x2800 || $codepoint > 0x28FF;
        
        return chr(0x2800 + (0x28FF - $codepoint));
    }
    return join('', map { invert_char($_) } split('', $string));
}

sub flip {
    my ($string) = @_;
    sub flip_char {
        my ($char) = @_;
        sub ror { # Rotate Right
            my ($val, $shift, $bits) = @_;
            $shift %= $bits;
            return (($val >> $shift) | ($val << ($bits - $shift))) & ((1 << $bits) - 1);
        }
        my $codepoint = ord($char);
        
        return $char if $codepoint < 0x2800 || $codepoint > 0x28FF;

        my $n = $codepoint-0x2800;
        
        return chr(0x2800 + (ror($n & 0b00111111, 3, 6) | (ror(($n & 0b11000000) >> 6, 1, 2)) << 6));
    }
    return join('', map { flip_char($_) } split('', $string));
}

if (!@ARGV) {
    usage;
    exit 1;
}

my $verb = shift @ARGV;

given ($verb) {
    when ('help')   { usage; }

    when ('table') {
        # NOTE: we are adding full block characters between the braille for readability
        for my $codepoint (0x2800..0x28FF) {
            printf "U+%04X: █%s█%s█%s█\n",
                $codepoint,
                chr($codepoint),
                invert(chr($codepoint)),
                flip(chr($codepoint))
            ;
        }
    }

    when ('invert') {
        my $input = do { local $/; <STDIN> };
        print invert($input);
    }

    when ('flip') {
        my $input = do { local $/; <STDIN> };
        print flip(decode("UTF-8", qx(echo "$input" | rev)));
    }

    default {
        print "Unknown verb: $verb\n";
        usage;
        exit 1;
    }
}
