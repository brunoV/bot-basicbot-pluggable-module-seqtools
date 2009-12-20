use Test::More;
use Test::Exception;
use Test::Bot::BasicBot::Pluggable;

my $bot = Test::Bot::BasicBot::Pluggable->new();
$bot->load('DNATools');

is ( $bot->tell_indirect('foo ATG'   ), '');

is ( $bot->tell_indirect('translate ATG'   ), 'M' );
is ( $bot->tell_indirect('translate ATG  0'), 'M' );
is ( $bot->tell_indirect('translate TATG 1'), 'M' );

lives_ok { $bot->tell_indirect('translate foo') };

like ( $bot->tell_indirect('translate ATG  5'   ), qr/^You.*/ );
like ( $bot->tell_indirect('translate ATG -1'   ), qr/^You.*/ );
like ( $bot->tell_indirect('translate ATG momma'), qr/^You.*/ );

#jis ( $bot->tell_indirect('foo'), 'bar');
#jis ( $bot->tell_private('foo'),  'bar');

done_testing();
