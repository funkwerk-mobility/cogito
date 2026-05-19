module cogito.tests.meter;

import cogito;
import cogito.configuration;
import cogito.list;
import cogito.meter;
import std.array;
import dmd.identifier;
import dmd.globals;
import dmd.location;
import std.algorithm;
import std.sumtype;

@("filename.d:line: identifier: score")
unittest
{
    enum string filename = "filename.d";
    auto meter = Meter(new Identifier(""), SourceLoc(filename, 2, 1), Meter.Type.callable);
    auto meters = List!Meter();

    meter.ownScore = 3;
    meters.insert(meter);

    auto source = Source(meters, filename);
    auto output = appender!string;
    auto reporter = FlatReporter!((string x) => output.put(x))(source);

    reporter.report(Threshold(1, 50));

    assert(output.data == "filename.d:2: function (λ): 3\n");
}

@("reporter prepends function identifiers with function")
unittest
{
    enum string filename = "filename.d";
    auto meter = Meter(new Identifier("f"), SourceLoc(filename, 2, 1), Meter.Type.callable);
    auto meters = List!Meter();

    meter.ownScore = 3;
    meters.insert(meter);

    auto source = Source(meters, filename);
    auto output = appender!string;
    auto reporter = FlatReporter!((string x) => output.put(x))(source);

    reporter.report(Threshold(1, 50));

    assert(output.data == "filename.d:2: function f: 3\n");
}

@("reports interface score")
unittest
{
    enum string filename = "filename.d";
    auto meter = Meter(new Identifier("I"), SourceLoc(filename, 2, 1), Meter.Type.interface_);
    auto meters = List!Meter();

    meter.ownScore = 3;
    meters.insert(meter);

    auto source = Source(meters, filename);
    auto output = appender!string;
    auto reporter = FlatReporter!((string x) => output.put(x))(source);

    reporter.report(Threshold(1, 2));

    assert(output.data == "filename.d:2: interface I: 3\n");
}

@("reports interface aggregate type")
unittest
{
    auto meter = runOnCode(q{
interface I
{
}
    });
    auto output = appender!string;
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold());

    assert(output.data.canFind("interface I"));
}

@("reports struct aggregate type")
unittest
{
    auto meter = runOnCode(q{
struct S
{
}
    });
    auto output = appender!string;
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold());

    assert(output.data.canFind("struct S"));
}

@("reports class aggregate type")
unittest
{
    auto meter = runOnCode(q{
class C
{
}
    });
    auto output = appender!string;
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold());

    assert(output.data.canFind("class C"));
}

@("reports union aggregate type")
unittest
{
    auto meter = runOnCode(q{
union U
{
    char a;
    byte b;
}
    });
    auto output = appender!string;
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold());

    assert(output.data.canFind("union U"));
}

@("reports template aggregate type")
unittest
{
    auto meter = runOnCode(q{
template T()
{
}
    });
    auto output = appender!string;
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold());

    assert(output.data.canFind("template T"));
}

@("reports only functions on function threshold violation")
unittest
{
    auto meter = runOnCode(q{
struct S
{
    void f()
    {
        if (true)
        {
        }
        else
        {
        }
    }

    void g()
    {
        if (true)
        {
        }
        else
        {
        }
    }
}
    });
    auto output = appender!string;
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold(1, 0));

    assert(!output.data.canFind("struct S"));
}

@("reports only functions on function threshold violation if aggregate threshold is set")
unittest
{
    auto meter = runOnCode(q{
struct S
{
    void f()
    {
        if (true)
        {
        }
        else
        {
        }
    }

    void g()
    {
        if (true)
        {
        }
        else
        {
        }
    }
}
    });
    auto output = appender!string;
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold(1, 10));

    assert(!output.data.canFind("struct S"));
}

@("does not report function when function is configured to be excluded")
unittest
{
    auto meter = runOnCode(q{
module g.h;

void f(char)
{
}

void f(bool)
{
    if (true)
    {
    }
    else
    {
    }
}
    });

    Configuration config;
    config.excludedModules["g.h"] = ExcludedModule();
    config.excludedModules["g.h"]["f"] = 8;

    auto output = appender!string;
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold(1, 0, 0, config));

    assert(!output.data.canFind("function f: 2\n"));
}

@("does not report function when function overload is configured to be excluded")
unittest
{
    auto meter = runOnCode(q{
module g.h;

void f(char)
{
}

void f(bool)
{
    if (true)
    {
    }
    else
    {
    }
}
    });

    Configuration config;

    config.excludedModules["g.h"] = ExcludedModule();
    config.excludedModules["g.h"]["f(bool)"] = 8;

    auto output = appender!string;
    auto reporter = meter.tryMatch!((Source source) =>
            FlatReporter!((string x) => output.put(x))(source));

    reporter.report(Threshold(1, 0, 0, config));

    assert(output.data.empty);
}
