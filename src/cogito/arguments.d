module cogito.arguments;

import argparse;
import std.algorithm;
import std.conv;
import std.format;
import std.range;
import std.traits;

// Help message.
private enum string returnCodes = q"HELP
  Return codes:
    0  Success
    1  Command line arguments are invalid
    2  Some source files contain errors
    3  Function threshold violation
    4  Aggregate threshold violation
    5  Module threshold violation
    6  Redundant threshold configuration found
HELP";

/**
 * Possible output formats.
 */
enum OutputFormat
{
    silent,
    flat,
    verbose,
    @AllowedValues("debug")
    debug_,
}

private enum string allowedOutputFormat(OutputFormat Member) =
    Member.to!string.strip('_');
private enum string[] allowedOutputFormats = [
    staticMap!(allowedOutputFormat, EnumMembers!OutputFormat)
];

/**
 * Arguments supported by the CLI.
 */
@(Command("cogito").Epilog(returnCodes))
struct Arguments
{
    /// Input files.
    @(PositionalArgument(0).Description("Source files or directories").Optional())
    string[] files = [];

    /// Module threshold.
    @(NamedArgument(["module-threshold"])
            .Optional()
            .Description("Fail if the source score exceeds this threshold")
            .Placeholder("NUMBER"))
    uint moduleThreshold = 0;

    /// Function threshold.
    @(NamedArgument(["threshold"])
            .Optional()
            .Description("Fail if a function score exceeds this threshold")
            .Placeholder("NUMBER"))
    uint threshold = 0;

    /// Aggregate threshold.
    @(NamedArgument(["aggregate-threshold"])
            .Optional()
            .Description("Fail if an aggregate exceeds this threshold")
            .Placeholder("NUMBER"))
    uint aggregateThreshold = 0;

    /// Output format.
    @(NamedArgument
            .Optional()
    )
    OutputFormat format = OutputFormat.flat;

    /// Show version.
    @(NamedArgument(["version"])
            .Optional()
            .Description("cōgitō version")
    )
    bool version_ = false;

    @(NamedArgument(["config"])
            .Optional()
            .Description("Configuration file")
     )
    string config;
}
