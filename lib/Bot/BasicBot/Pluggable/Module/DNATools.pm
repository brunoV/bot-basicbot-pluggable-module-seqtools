package Bot::BasicBot::Pluggable::Module::DNATools;
use base 'Bot::BasicBot::Pluggable::Module';
use Modern::Perl;
use Try::Tiny;
use Bio::Seq;
use Bio::SeqFeature::Primer;

sub told {
    my ($self, $msg) = @_;

    # They address us specifically, do nothing.
    return unless $msg->{address};

    state $commands = [qw(
        translate
        reverse
        complement
        revcomp
        composition
        tm
    )];

    my (@tokens) = split /\s+/, $msg->{body};

    my @commands;

    # extract all the commands
    while ( $tokens[0] ~~ @$commands ) {
        unshift @commands, shift @tokens;
    }

    # The rest should be a sequence and possibly arguments
    my ($seq, @args) = @tokens;

    return if not ( @commands and $seq );

    return invalid_dna_msg() unless $self->is_valid($seq);

    # Get the result for the innermost command
    my $message = apply(shift @commands, $seq, @args);

    # If there are commands left to apply, do it with the previous
    # return value.
    while (my $command = shift @commands) {
        $message = apply($command, $message);
    }

    return $message;
}

sub apply {
    my ($command, $seq, @args) = @_;

    given ($command) {
        when ('translate'  )   { return translate  ($seq, @args) }
        when ('reverse'    )   { return reverse_str($seq)        }
        when ('complement' )   { return complement ($seq)        }
        when ('revcomp'    )   { return revcomp    ($seq)        }
        when ('composition')   { return composition($seq)        }
        when ('tm'         )   { return tm         ($seq, @args) }
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

    my ($seq, @args) = @_;

    my $salt  = shift @args || 0.05;
    my $oligo = shift @args || 0.00000025;

    my $error;

    my $tm = try   {
        Bio::SeqFeature::Primer->new( -seq => $seq  )
            ->Tm( -salt  => $salt,  -oligo => $oligo);
    }
    catch {

        # If we are here, most probably the Tm(@args) are wrong
        $error = "Wrong arguments: tm <seq> [salt] [oligo] (in Molar)";

        return;
    };

    return $tm ? sprintf("%.2f ºC", $tm) : $error;
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
    tm          <seq>         # Calculate the melting temperature
END

    return $usage;
}

1;
