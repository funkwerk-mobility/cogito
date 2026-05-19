module cogito.tests.visitor;

import cogito;
import std.sumtype;

@("static if counts as if")
unittest
{
    auto meter = runOnCode(q{
struct S
{
    static if (true)
    {
    }
    else
    {
    }
}
    });

    assert(meter.tryMatch!((Source source) => source.score) == 2);
}
