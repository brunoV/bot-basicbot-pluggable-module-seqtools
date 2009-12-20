package Bot::BasicBot::Pluggable::Module::DNATools;
use base 'Bot::BasicBot::Pluggable::Module';
use Modern::Perl;
use Try::Tiny;
use Bio::Seq;
use Bio::SeqFeature::Primer;

my $Previous; # Remember last thing said

sub said {
    my ($self, $msg) = @_;

    state $commands = [qw(
        translate
        reverse
        complement
        revcomp
        composition
        tm
    )];

    my ($command, $seq, @args) = split /\s+/, $msg->{body};

    $Previous = $command;

    unless ( $command ~~ @$commands and $seq ) { return }

    $seq = $Previous if $seq eq '^^';

    return invalid_dna_msg() unless $self->is_valid($seq);

    given ($command) {
        when ('translate'  )   { return translate  ($seq, @args) }
        when ('reverse'    )   { return reverse_str($seq)        }
        when ('complement' )   { return complement ($seq)        }
        when ('revcomp'    )   { return revcomp    ($seq)        }
        when ('composition')   { return composition($seq)        }
        when ('tm'         )   { return tm         ($seq)        }
    }
}

sub translate {
    my ($seq, $frame) = @_;

    $frame //= 0;

    if ( !grep { $frame eq $_ } (0, 1, 2) ) {
        return "Your frame is wrong, must be either 0, 1, or 2";
    }

    my $seq_obj = try { Bio::Seq->new( -seq => $seq ) };

    return if not defined $seq_obj;

    my $translated = try {
        $seq_obj->translate( -frame => $frame )->seq
    } catch { 'Error translating' };

    return $translated;
}

sub reverse_str {
    my ($str) = @_;

    return scalar reverse $str;
}

sub complement {
    my ($seq) = shift;

    # For now, only [GATCU] will come this way because of previous
    # validation, but I'll still keep this sub like this just in case
    # we'll need it later
    $seq =~ tr{atugcyrkmbdhvATUGCYRKMBDHV}
              {taacgrymkvhdbTAACGRYMKVHDB};

    return $seq;
}

sub revcomp {
    return reverse_str(complement(shift));
}

sub is_valid {
    my ($self, $seq) = @_;

    return $seq !~ /[^ACGTUacgtu]/;
}

sub invalid_dna_msg {

    state $messages = [
        "Your DNA input is ALL WRONG!",
        "I.. I think that's not quite right.",
        "Mmh. Please check that sequence, I don't like it.",
        "Dude. Check your purines, polymerases wouldn't touch that with a ten-foot pole.",
        "No, no NOOO! Horrible input. I'm ashamed for both of us.",
        "If that's supposed to represent a polymer of nucleotides, then I'm the digital reincarnation of Evita.",
    ];

    return $messages->[rand @$messages];
}

sub composition {
    my $seq = uc shift or return;

    my @bases = split '', $seq;
    my $total = @bases;

    # Count the letters
    my %composition;
    while (my $base = shift @bases) { ++$composition{$base} }

    # Divide by the total letters and multiply by 100
    map { $composition{$_} *= 100/$total } keys %composition;

    # Create a pretty string with the results for output
    my $result_str;
    foreach my $base (sort keys %composition) {
        $result_str .= sprintf("%s:%.1f%% ", $base, $composition{$base});
    }

    return $result_str;
}

sub tm {

    my $seq = shift;

    my $tm = try   { Bio::SeqFeature::Primer->new( -seq => $seq )->Tm }
             catch { return "Something went wrong" };

    return sprintf("%.2f ºC", $tm);
}

sub help {

    my $usage = <<END;
Various tools for DNA sequences: translation, reverse complement, composition, etc.
Usage:

    translate   <seq> [FRAME] # Translates DNA to protein
    composition <seq>         # Base pair composition
    revcomp     <seq>         # Reverse complement
    reverse     <seq>         # Reverse
    complement  <seq>         # Base pair complement
END

    return $usage;
}

1;
