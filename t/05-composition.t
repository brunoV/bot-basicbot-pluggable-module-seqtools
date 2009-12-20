use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('DNATools');

is $bot->tell_indirect('composition ACGT'),
   'A:25.0% C:25.0% G:25.0% T:25.0% ';

is $bot->tell_indirect('composition AAaa'), 'A:100.0% ';

#jis ( $bot->tell_indirect('foo'), 'bar');
#jis ( $bot->tell_private('foo'),  'bar');

done_testing();
