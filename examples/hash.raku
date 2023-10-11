use OTPish::Process;
use OTPish::Task;
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
    my %hash := OTPish::Hash.new;    # Create a new Hash as an implementation of Agent
    %hash.spawn;
    my @tasks = do for ^100 {
        async {
            %hash{$_} = True;        # queue 100 pairs to be inserted
        }
    }
    @tasks>>.await;
    say %hash.keys.elems             # 1000
}
