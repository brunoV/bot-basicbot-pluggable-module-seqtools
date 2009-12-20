use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('DNATools');

is ( $bot->tell_indirect('foo ATG'   ), '');

is ( $bot->tell_indirect('complement ATG'), 'TAC' );

done_testing();
