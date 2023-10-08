use OTPish::Process;
unit class OTPish::Task is OTPish::Process;

multi method async(::?CLASS:U: &code) {
    my $new = self.new: :&code;
    $new.async
}

multi method async(::?CLASS:D:) {
    self.spawn
}

method await {
    await self.prom
}
