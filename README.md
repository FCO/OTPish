[![Actions Status](https://github.com/FCO/OTPish/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/OTPish/actions)

NAME
====

OTPish - A Elixir's OTP's copy for Raku

SYNOPSIS
========

```raku
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
```

```raku
use OTPish::Process;
use OTPish::GenServer;

class OTPish::Stack is OTPish::GenServer does Associative {
    method new {
        my $self = callwith :state[];
        $self.spawn;
        $self
    }

    # client
    method push($push) { self.cast: :$push }
    method pop         { self.call: :pop   }

    # server
    multi method handle-cast(@state, :$push)                     { \( :noreply[$push, |@state] ) }
    multi method handle-call([$first, *@state], :$pop, :from($)) { \( :reply(@state), $first   ) }
}

 main-process {
     my $stack = OTPish::Stack.new;
     $stack.push: 42;
     $stack.push: 13;
     say $stack.pop;     # 13
     $stack.push: 3.14;
     say $stack.pop;     # 3.14
     say $stack.pop;     # 42
 }
```

DESCRIPTION
===========

OTPish is Elixir's OTP's copy for Raku

AUTHOR
======

Fernando Corrêa <fernando.correa@humanstate.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2023 Fernando Corrêa

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

