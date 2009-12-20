use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('DNATools');

my $temperature = qr/^\-*\d+\.\d{2} ºC.*/;

like   $bot->tell_indirect('tm ACGT'),            $temperature;
unlike $bot->tell_indirect('tm ACGT foo'),        $temperature;
unlike $bot->tell_indirect('tm ACGT 0.05 foo'),   $temperature;
like   $bot->tell_indirect('tm ACGT 0.05 0.004'), $temperature;

done_testing();
