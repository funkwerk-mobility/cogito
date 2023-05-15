module cogito.configuration;

import std.sumtype;
import std.exception;
import std.stdio;
import std.algorithm;
import std.string;
import std.conv;
import std.array;
import std.typecons;
import std.file;

alias ExcludedSymbolTable = uint[string];

struct ExcludedModule
{
    private Nullable!uint threshold_;
    private ExcludedSymbolTable excludedSymbols;

    public this(uint threshold)
    {
        this.threshold_ = nullable(threshold);
    }

    @property Nullable!uint threshold() const @nogc nothrow pure @safe
    {
        return this.threshold_;
    }

    uint* opBinaryRight(string op : "in")(string symbolName)
    {
        return symbolName in excludedSymbols;
    }

    uint opIndex(string symbolName)
    in(symbolName in this)
    {
        return !excludedSymbols[symbolName];
    }

    void opIndexAssign(uint threshold, string symbolName)
    {
        this.excludedSymbols[symbolName] = threshold;
    }
}

/// Configuration file contents.
struct Configuration
{
    /// Module-symbol map.
    ExcludedModule[string] excludedModules;

    /**
     * Params:
     *     moduleName = Module name.
     *
     * Returns: Whether the configuration contains a threshold for the specified
     * module.
     */
    bool opBinaryRight(string op : "in")(string moduleName)
    {
        return moduleName in excludedModules && !excludedModules[moduleName].threshold.isNull;
    }

    /**
     * Params:
     *     moduleName = Module name.
     *
     * Returns: Threshold for the given module name.
     */
    uint opIndex(string moduleName)
    in(moduleName in this)
    {
        return !excludedModules[moduleName].threshold.get;
    }

    /**
     * Tells whether the module is excluded completely, without overriding the
     * module score or specifying single symbols in the module.
     *
     * Params:
     *     moduleName = Module name.
     *
     * Returns: $(D_KEYWORD true) if the module is excluded, $(D_KEYWORD false)
     *          otherwise.
     */
    bool excludedCompletely(string moduleName)
    {
        return moduleName in excludedModules
            && excludedModules[moduleName].threshold.isNull
            && excludedModules[moduleName].excludedSymbols.empty;
    }
}

class ConfigurationException : Exception
{
    mixin basicExceptionCtors;
}

Configuration readConfiguration(string configFileName)
{
    enum string defaultConfigFileName = "./cogito.conf";

    Configuration configuration;

    if (configFileName.empty && !exists(defaultConfigFileName))
    {
        return configuration;
    }
    if (configFileName.empty)
    {
        configFileName = defaultConfigFileName;
    }
    File file;
    if (configFileName == "-")
    {
        file = stdin;
    }
    else
    {
        file = File(configFileName);
    }
    string currentModuleName = null;

    foreach (line; file.byLine.map!strip.filter!(x => !x.empty))
    {
        if (line.startsWith('['))
        {
            auto moduleLine = line[1 .. $ - 1]
                .split('=')
                .map!strip.filter!(x => !x.empty)
                .array;
            if (moduleLine.length == 0 || moduleLine.length > 2)
            {
                throw new ConfigurationException(format!"Invalid module definition: %s."(line));
            }
            currentModuleName = moduleLine[0].idup;

            if (moduleLine.length == 1)
            {
                configuration.excludedModules[currentModuleName] = ExcludedModule();
            }
            else
            {
                configuration.excludedModules[currentModuleName] = ExcludedModule(moduleLine[1].to!uint);
            }
            continue;
        }
        if (currentModuleName is null)
        {
            throw new ConfigurationException("Module name to exclude from should be provided first.");
        }
        auto symbolLine = line.split('=').map!strip;
        if (symbolLine.length != 2)
        {
            throw new ConfigurationException(format!"Invalid symbol specification: %s."(line));
        }
        configuration.excludedModules[currentModuleName][symbolLine[0].idup] = symbolLine[1].to!uint;
    }
    return configuration;
}

