package MojoX::Session::Adapter::PSGI;
use 5.010001;
use Mojo::Base 'Mojolicious::Sessions';
our $VERSION = "0.01";



1;
__END__

=encoding utf-8

=head1 NAME

MojoX::Session::Adapter::PSGI - PSGI session adapter for Mojolicious

=head1 SYNOPSIS

    use MojoX::Session::Adapter::PSGI;

    $app->sessions(MojoX::Session::Adapter::PSGI->new({
        ...
    });

=head1 DESCRIPTION

MojoX::Session::Adapter::PSGI is ...

=head1 LICENSE

Copyright (C) yowcow.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

yowcow E<lt>yowcow@cpan.org<gt>

=cut

