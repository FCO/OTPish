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
