import cogito;

import argparse : CLI;
import cogito.arguments;
import std.algorithm;
import std.sumtype;
import std.functional;
import std.stdio;
import std.range;
import cogito.configuration;

int accumulateResult(Arguments arguments, Configuration configuration, int accumulator, Result result)
{
    auto nextResult = match!(
        (List!CognitiveError errors) {
            printErrors(errors);
            return 2;
        },
        (Source source) {
            auto threshold = Threshold(arguments.threshold,
                arguments.aggregateThreshold, arguments.moduleThreshold,
                configuration);
            const result = report(source, threshold, arguments.format);
            final switch (result)
            {
            case ThresholdResult.success:
                return 0;
            case ThresholdResult.function_:
                return 3;
            case ThresholdResult.aggregate:
                return 4;
            case ThresholdResult.module_:
                return 5;
            case ThresholdResult.redundant:
                return 6;
            }
        }
    )(result);
    if (accumulator == 2 || nextResult == 2)
    {
        return 2;
    }
    else if (accumulator != 0)
    {
        return accumulator;
    }
    return nextResult;
}

int printVersion()
{
    write("cōgitō " ~ import("githash.txt"));
    write("  based on DMD " ~ import("VERSION"));
    return 0;
}

int noFilesError()
{
    stderr.writeln("No input files specified.");
    return 1;
}

mixin CLI!Arguments.main!((arguments) {
    if (arguments.version_)
    {
        return printVersion();
    }
    if (arguments.files.empty)
    {
        return noFilesError();
    }
    auto configuration = readConfiguration(arguments.config);
    try
    {
        return runOnFiles(arguments.files)
            .fold!((accumulator, result) => accumulateResult(arguments, configuration, accumulator, result))(0);
    }
    catch (Exception exception)
    {
        stderr.writefln!"Error: %s"(exception.msg);
        return 1;
    }
});
