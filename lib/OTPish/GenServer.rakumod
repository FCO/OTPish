use OTPish::Process;
unit class OTPish::GenServer is OTPish::Process;

subset false of Bool where *.not;
subset true  of Bool where *.so;

method new(:$state is copy, |) {
    nextwith code => sub {
        my Channel $channel = $*OTPish-PROCESS.channel;
        react {
            whenever $channel -> $msg {
                proto handle(|) {*}
                multi handle(OTPish::Process $from, Capture :$call!) {
                    CATCH {
                        default {
                            $from.send: \(:error($_))
                        }
                    }
                    my ($reply, $response);
                    :($response, :$reply) := self.handle-call: |$call, :$from, $state;
                    $state = $reply;
                    $from.send: \(:ok($response))
                }
                multi handle(Capture :$cast!) {
                    my $noreply;
                    :(:$noreply) := self.handle-cast: |$cast, $state;
                    $state = $noreply;
                }

                handle |$msg
            }
        }
    }
}

method call(|call) {
    self.send: \(:call(call), $*OTPish-PROCESS);
    receive
      -> :$error! {
          die $error
      },
      -> :$ok! {
          return $ok
      }
}

method cast(|cast) {
    self.send: \(:cast(cast));
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
