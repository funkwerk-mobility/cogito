module cogito.tests.compilation;

import cogito;
import std.sumtype;

@("shortened methods")
unittest
{
    auto meter = runOnCode(q{
int foo() => 3;
    });

    assert(!meter.tryMatch!((Source source) => source.inner[]).empty);
}
