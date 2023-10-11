use OTPish::Process;
unit class OTPish::Task is OTPish::Process;

multi method async(::?CLASS:U: &code, $parent = $*OTPish-PROCESS) {
    my $new = self.new: :code{
        CATCH {
            default {
                .say
            }
        }
        my $pid = $parent.pid;
        $parent.send: \( :await($pid), code() ); 
    }
    $new.async
}

multi method async(::?CLASS:D:) {
    self.spawn
}

method await {
    my $pid = $*OTPish-PROCESS.pid;
    receive -> \ret, :$await! where $pid { return ret }
}

sub async(&code) is export {
    ::?CLASS.async: &code
}
