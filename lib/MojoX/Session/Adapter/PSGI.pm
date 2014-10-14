package MojoX::Session::Adapter::PSGI;
use 5.010001;
use Mojo::Base 'Mojolicious::Sessions';
our $VERSION = "0.01";

sub load {
    my ($self, $c) = @_;
    my $session = $c->req->env->{'psgix.session'};
    $c->stash->{'mojo.session'} = $session;

    ## "expiration" value is inherited
    my $expiration = $session->{expiration} // $self->default_expiration;

    my $remove_session = sub { delete @$session{ keys %$session } };

    $remove_session->() and return
            if !(my $expires = delete $session->{expires}) && $expiration;
    $remove_session->() and return
            if defined $expires && $expires <= time;

    my $stash = $c->stash;
    $remove_session->() and return
            unless $stash->{'mojo.active_session'} = keys %$session;
    $session->{flash} = delete $session->{new_flash} if $session->{new_flash};
}

sub store {
    my ($self, $c) = @_;
    my $env = $c->req->env;

    # Make sure session was active
    my $stash = $c->stash;
    return unless my $session = $stash->{'mojo.session'};
    return unless keys %$session || $stash->{'mojo.active_session'};

    # Don't reset flash for static files
    my $old = delete $session->{flash};
    $session->{new_flash} = $old if $stash->{'mojo.static'};
    delete $session->{new_flash} unless keys %{$session->{new_flash}};

    # Generate "expires" value from "expiration" if necessary
    my $expiration = $session->{expiration} // $self->default_expiration;
    my $default = delete $session->{expires};
    $session->{expires} = $default || time + $expiration
            if $expiration || $default;

    my $regenerate = delete $session->{regenerate};
    delete $session->{flash} if exists $session->{flash};

    if (defined($session->{expires}) && $session->{expires} <= time) {
        $env->{'psgix.session.options'}{expire} = 1;
    }
    elsif ($regenerate) {
        $env->{'psgix.session.options'}{change_id} = 1;
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

MojoX::Session::Adapter::PSGI - PSGI session adapter for Mojolicious

=head1 SYNOPSIS

    # Replace default session manager
    use MojoX::Session::Adapter::PSGI;

    my $sessions = MojoX::Session::Adapter::PSGI->new({
        default_expiration => 24 * 60 * 60, # 24 hours
    });

    $mojo_app->sessions($sessions);

    # In app.psgi, build app to use Plack::Middleware::Session or similar.
    # As an example, you may choose Plack::Middleware::Session::Simple
    use Mojolicious::Lite;
    use Plack::Builder;

    build {
        enable 'Session::Simple,
            store => Cache::Memcached::Fast->new( ... ),
            cookie_name => 'my-test-app-session';

        app->start;
    };

=head1 DESCRIPTION

MojoX::Session::Adapter::PSGI enables L<Mojolicious> app to load/store
session through C<psgix.session> key in the C<$env> without making
changes to your existing controller codes.

The simplest usage is to build your Mojolicious app to use
L<Plack::Middleware::Session::Simple> through L<Plack::Builder>,
and this adapter will do the bridge between C<psgix.session> and
L<Mojolicious::Sessions>.

=head1 ATTRIBUTES

L<MojoX::Session::Adapter::PSGI> uses the following attributes
implemented on L<Mojolicious::Sessions>.

=head2 default_expiration

For details, see L<Mojolicious::Sessions>.

=head1 METHODS

=head2 load

Load session data from C<$env->{'psgix.session'}> into C<$c->stash->{'mojo.session'}>.
Session data will be deleted if the session is expired.

=head2 store

Store session data from C<$c->stash->{'mojo.session'}> into C<$env->{'psgix.session'}>.
You may regenerate session ID by setting the following flag in session data:

=over 4

=item * regenerate

L<MojoX::Session::Adapter::PSGI> sets C<$env->{'psgix.option'}{change_id} = 1> when:

    $c->session({ regenerate => 1 });

=back

=head1 LICENSE

Copyright (C) yowcow.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

yowcow E<lt>yowcow@cpan.org<gt>

=cut

