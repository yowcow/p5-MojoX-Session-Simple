requires 'perl', '5.010001';

requires 'Mojolicious';
requires 'Plack::Middleware::Session::Simple';

on 'test' => sub {
    requires 'Cache::Memory::Simple';
    requires 'HTTP::CookieJar';
    requires 'HTTP::Request::Common';
    requires 'Test::More', '0.98';
    requires 'Test::Pretty';
    requires 'Test::TCP';
};

