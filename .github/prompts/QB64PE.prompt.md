# TERMINAL 
0. Navigate and run the test in one command
1. ALWAYS `cd` to the directory and `&&` run the execution of commands.
2. your cd commands must be executed and && with the .run!
3. If you cannot work within the existing terminal window and need to open a new one make sure you cd to the place you need to go first.
4. Example: `cd /Users/grymmjack/git/img2ans/include/BOUNDING_BOX && ./ENHANCED_BBOX_TEST.run`


# BUILDING QB64PE 

> To build QB64PE use this path: `/Users/grymmjack/git/qb64pe/qb64pe`

This is where the compiler exists.

## Compilation Options

From: `/Users/grymmjack/git/qb64pe/qb64pe -h`
```
QB64-PE Compiler V4.2.0-UNKNOWN

USAGE: qb64pe [options] <source file> [-o <output file>]

Info Options (no files required):
  -?, -h, --help       Show this help text
  -v                   Show version information

File specifications:
  <source file>        Source file to load into IDE, to format or compile
  -o <output file>     Write result to <output file>
                         - optionally override the default executable name
                         - is mandatory for code formatting (-y option)

IDE Options:
  -l:<line number>     Load <source file> into the IDE and move cursor to
                       the given <line number>, if possible

Compiler Options (no IDE):
  -c                   Compile <source file> (show progress in own window)
  -x                   Like -c, but progress goes to console (no own window)
  -y                   Output (re)formatted <source file> to -o <output file>
  -z                   Generate C code from <source file> without compiling
                       the executable (C code output goes to internal\temp)
                         - may be used to quickly check for syntax errors

Extended Compiler Options:
  -p                   Purge all pre-compiled content first
  -e                   Enforce variable declaration even if no OPTION _EXPLICIT
                       was used in the <source file>
                         - per compilation, doesn't change the <source file>
  -s[:setting=value]   View and/or edit & save compiler settings permanently

Temporary Compiler Options:
  -f[:setting=value]   Compiler and/or formatting settings to use
                         - per compilation, doesn't change global defaults

Reporting Options:
  -w                   Show warnings (such as unused variables etc.)
  -q                   Quiet mode (no progress, but warnings/errors, if any)
  -m                   Do not colorize compiler outputs (monochrome mode)

     ----------------------------------------------------------------------

Supported (-s) Compiler settings:
  -s                              Show the current state of all settings
  -s:DebugInfo=[true|false]       Embed C++ debug info into executable
  -s:ExeWithSource=[true|false]   Save executable in the source folder
      You may specify a setting without equal sign and value to
      show the current state of that specific setting only.

     ----------------------------------------------------------------------

Note:
  Defaults for the following settings can be set via the IDE Options menu,
  any values given here are just temporary overrides per compilation.

Supported (-f) Compiler settings:
  -f                                    Show this list of supported settings
  -f:OptimizeCppProgram=[true|false]    Compile with C++ Optimization flag
  -f:StripDebugSymbols=[true|false]     Strip C++ Symbols from executable
  -f:ExtraCppFlags=[string]             Extra flags for the C++ Compiler
  -f:ExtraLinkerFlags=[string]          Extra flags for the Linker
  -f:MaxCompilerProcesses=[integer]     Max C++ Compiler processes to use
  -f:GenerateLicenseFile=[true|false]   Produce a license.txt file for program
  -f:UseSystemCompiler=[true|false]     Use the system C++ compiler instead of
                                        the bundled one (Windows only)

Supported (-f) Layout settings:
  -f:AutoIndent=[true|false]            Auto Indent lines
      The next two also require the above to be enabled or they will have
      no effect, unless AutoIndent is enabled per default in the IDE.
  -f:AutoIndentSize=[integer]           Indent Spacing per indent level
  -f:IndentSubs=[true|false]            Indent SUBs and FUNCTIONs
  -f:AutoLayout=[true|false]            Auto Single-spacing of code elements
      The next two work together, if both are given with the same state
      it's CaMeL case, otherwise the enabled one determines the case,
      hence no need to specify both if you just want UPPER or lower case.
      If none is given the default as set in the IDE is used.
  -f:KeywordCapitals=[true|false]       Make keywords to ALL CAPITALS
  -f:KeywordLowercase=[true|false]      Make keywords to ALL lower case
```

## Compiling to disk
Use this command: `/Users/grymmjack/git/qb64pe/qb64pe -w -x ${fileDirname}/${fileBasename} -o ${fileDirname}/${fileBasenameNoExtension}.run`

## Running the file
*** ALWAYS `cd` to the directory and `&&` run the execution of commands.
Example: `cd /Users/grymmjack/git/img2ans/include/BOUNDING_BOX && ./ENHANCED_BBOX_TEST.run`
- Hint from: `"${fileDirname}/${fileBasenameNoExtension}.run"`

## Logging to console:

When you need to see what a user might see or things changing,
log to the console so you can see your own output/interactions.

```qb64
$CONSOLE
_CONSOLE ON
DIM oldDest AS INTEGER
oldDest% = _DEST
_DEST _CONSOLE
PRINT "This goes to console"
_DEST oldDest%
PRINT "This goes to the program window"
```

