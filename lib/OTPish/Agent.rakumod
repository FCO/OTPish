use OTPish::Process;
unit class OTPish::Agent is OTPish::Process;

method new(:$state is copy, OTPish::Process :$parent = $*OTPish-PROCESS) {
    nextwith code => sub {
        CATCH { default { .say } }
        my OTPish::Agent $SELF    = $*OTPish-PROCESS;
        my Channel       $channel = $SELF.channel;
        react {
            CATCH { default { .say } }
            whenever $channel -> $msg {
                CATCH { default { .say } }
                proto handle(OTPish::Process, |) {*}
                multi handle(OTPish::Process $from, :&get!) {
                    $from.send: \(:ok(get $state), :from($SELF))
                }
                multi handle(OTPish::Process $from, :&update!) {
                    $state = update $state;
                }
                multi handle(OTPish::Process $from, :&get-and-update!) {
                    my :($ok, $new-state) := get-and-update $state;
                    $state = $new-state;
                    $from.send: \(:$ok, :from($SELF))
                }
                multi handle(|c) {
                    Promise.in(0.1).then: { self.send: |c }
                }

                handle |$msg
            }
        }
    }
}

method get(&get, OTPish::Process :$from = $*OTPish-PROCESS) {
    self.send: \(:&get, $from);
    receive
      -> Str :$error! {
          die $error
      },
      -> :$ok!, :$from! where *.pid eq $.pid {
          return $ok
      }
}

method update(&update, OTPish::Process :$from = $*OTPish-PROCESS) {
    self.send: \(:&update, $from);
}

method get-and-update(&get-and-update, OTPish::Process :$from = $*OTPish-PROCESS) {
    self.send: \(:&get-and-update, $from);
    receive
      -> Str :$error! {
          die $error
      },
      -> :$ok!, :$from! where *.pid eq $.pid {
          return $ok
      }
}

sub agent($state) is export {
    ::?CLASS.new: :$state
}
