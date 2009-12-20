use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('SeqTools');

my $mw = qr/MW: \d+\.\d{2}/;

like $bot->tell_direct('mw AAAAA'     ), $mw;
like $bot->tell_direct('mw MAAELLVIKP'), $mw;

done_testing();
