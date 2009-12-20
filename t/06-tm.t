use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('DNATools');

like $bot->tell_indirect('tm ACGT'), qr/^\-*\d+\.\d{2} ºC.*/;

done_testing();
