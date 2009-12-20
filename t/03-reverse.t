use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('DNATools');

is ( $bot->tell_indirect('foo ATG'   ), '');

is ( $bot->tell_indirect('reverse ATG'), 'GTA' );

#jis ( $bot->tell_indirect('foo'), 'bar');
#jis ( $bot->tell_private('foo'),  'bar');

done_testing();
