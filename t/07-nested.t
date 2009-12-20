use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('DNATools');

is $bot->tell_indirect('composition reverse complement AAAAA'),
   'T:100.0% ';

my $tm = qr/^\-*\d+\.\d{2} ºC.*/;

like $bot->tell_indirect('tm reverse complement GAATTCCGGCCGGT'), $tm;

is $bot->tell_indirect('reverse complement reverse complement GAATCCG'),
   'GAATCCG';

done_testing();
