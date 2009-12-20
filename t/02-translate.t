use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('DNATools');

is ( $bot->tell_direct('foo ATG'   ), '');

is ( $bot->tell_direct('translate ATG'   ), 'M' );
is ( $bot->tell_direct('translate ATG  0'), 'M' );
is ( $bot->tell_direct('translate TATG 1'), 'M' );

lives_ok { $bot->tell_direct('translate foo') };

like ( $bot->tell_direct('translate ATG  5'   ), qr/^You.*/ );
like ( $bot->tell_direct('translate ATG -1'   ), qr/^You.*/ );
like ( $bot->tell_direct('translate ATG momma'), qr/^You.*/ );

done_testing();
