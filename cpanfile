requires 'perl', '5.008001';

requires 'Mojolicious';

on 'test' => sub {
    requires 'Plack::Middleware::Session::Simple';
    requires 'Test::More', '0.98';
    requires 'Test::Pretty';
};

