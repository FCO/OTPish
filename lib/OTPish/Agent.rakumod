use OTPish::Process;
unit class OTPish::Agent is OTPish::Process;

subset false of Bool where *.not;
subset true  of Bool where *.so;

method new(:$state is copy, |) {
    nextwith code => sub {
        my Channel $channel = $*OTPish-PROCESS.channel;
        react {
            whenever $channel -> $msg {
                proto handle(OTPish::Process, |) {*}
                multi handle(OTPish::Process $from, :&get!) {
                    $from.send: \(:ok(get $state))
                }
                multi handle(OTPish::Process $from, :&update!) {
                    $state = update $state;
                    $from.send: \(:ok)
                }
                multi handle(OTPish::Process $from, :&get-and-update!) {
                    my $ok;
                    :($ok, $state) := get-and-update $state;
                    $from.send: \(:$ok)
                }

                handle |$msg
            }
        }
    }
}

method get(&get) {
    self.send: \(:&get, $*OTPish-PROCESS);
    receive
      -> Str :$error! {
          die $error
      },
      -> :$ok! {
          return $ok
      }
}

method update(&update) {
    self.send: \(:&update, $*OTPish-PROCESS);
    receive
      -> Str :$error! {
          die $error
      },
      -> :$ok! { return }
}

method get-and-update(&get-and-update) {
    self.send: \(:&get-and-update, $*OTPish-PROCESS);
    receive
      -> Str :$error! {
          die $error
      },
      -> :$ok! {
          return $ok
      }
}

sub agent($state) is export {
    ::?CLASS.new: :$state
}
