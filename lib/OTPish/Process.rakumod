use OTPish;
unit class OTPish::Process does OTPish;

sub receive(*@f, Channel :$channel = $*OTPish-PROCESS.channel) is export {
    loop {
        my $last;
        given $channel.receive -> \res {
            for @f -> &func {
                when res.Capture ~~ &func.signature {
                    return func |res;
                }
            }
            $last = res
        }
        Promise.in(0.1).then: {
            $channel.send: $last
        }
    }
}

my atomicint $next-id = 0;

has UInt     $.id = $next-id++;
has          &.code;
has Promise  $.prom;
has Channel  $.channel .= new;
has ::?CLASS $.parent;
has Lock     $!lock .= new;

method send(|c) {
    $!lock.protect: { $!channel.send: |c }
}

method pid(::?CLASS:D:) { "{ self.^name }-{ $!id }" }

multi method gist(::?CLASS:D:) { $.pid }

method alive { $!prom.status ~~ Planned }

multi method spawn(::?CLASS:D:) {
    $!prom = start {
        my $*OTPish-PROCESS = self;
        &!code.();
    }
    self
}

multi method spawn(::?CLASS:U: &code) {
    my $new = self.new: :&code;
    $new.spawn;
    $new
}

sub spawn(&code) is export {
    ::?CLASS.spawn: &code
}

sub main-process(&code) is export {
    await spawn(&code).prom
}

sub process is export { $*OTPish-PROCESS }
