use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('SeqTools');

is ( $bot->tell_direct('foo ATG'   ), '');

is ( $bot->tell_direct('reverse ATG'), 'GTA' );

done_testing();
