unit role OTPish;

=begin pod

=head1 NAME

OTPish - A Elixir's OTP's copy for Raku

=head1 SYNOPSIS

=begin code :lang<raku>
use OTPish::Process;
use OTPish::Agent;

class OTPish::Hash is OTPish::Agent does Associative {
    method new {
        my $self = callwith :state(%());
        $self.spawn;
        $self
    }
    method keys  { self.get: *.keys  }
    method elems { self.get: *.elems }
    method AT-KEY($SELF: |c) is raw {
        Proxy.new:
          :FETCH{ $SELF.get: *.AT-KEY: |c },
          :STORE(
              method ($value) {
                  $SELF.update: {
                      .AT-KEY(|c) = $value;
                      %$_
                  }
              }
          )
    }
}

main-process {
    my %hash := OTPish::Hash.new;                  # Create a new Hash as an implementation of Agent
    ^1000 .race(:1batch).map: { %hash{$_} = True } # Insert 1000 pairs in parallel (no race condition)
    say %hash.keys.elems                           # 1000
}

=end code

=head1 DESCRIPTION

OTPish is Elixir's OTP's copy for Raku

=head1 AUTHOR

Fernando Corrêa <fernando.correa@humanstate.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2023 Fernando Corrêa

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
