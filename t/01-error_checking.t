use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('DNATools');

is ( $bot->tell_direct('foo ATG'   ), '');

like( $bot->tell_direct('help dnatools'), qr/^Various.*/ );

my @commands = qw(translate reverse revcomp complement composition);

foreach my $command (@commands) {
    lives_ok { $bot->tell_direct("$command  foo") };
}

done_testing();
