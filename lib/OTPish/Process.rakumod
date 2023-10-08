use OTPish;
unit class OTPish::Process does OTPish;

sub receive(*@f) is export {
    loop {
        given $*OTPish-PROCESS.channel.receive {
            for @f -> &func {
                when .Capture ~~ &func.signature {
                    return func |$_;
                }
            }
        }
    }
}

my atomicint $next-id = 0;

has UInt     $.id = $next-id++;
has          &.code;
has Promise  $.prom;
has Channel  $.channel handles <send> .= new;
has ::?CLASS $.parent;

multi method gist(::?CLASS:D:) { "{ self.^name }-{ $!id }" }

method alive { $!prom.status !~~ Planned }

multi method spawn(::?CLASS:D:) {
    $!prom = start {
        my $*OTPish-PROCESS = self;
        &!code.()
    }
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
