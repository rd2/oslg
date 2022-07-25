# oslg

A logger module for _picky_ [OpenStudio](https://openstudio-sdk-documentation.s3.amazonaws.com/index.html) [Measure](https://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/) developers who wish to select what gets logged to which target (e.g. OpenStudio _runner_ vs custom JSON file). Add:

```
gem "oslg", git: "https://github.com/rd2/oslg", branch: "main"
```

... in a measure's development environment "Gemfile", and then run:

```
bundle install
```

### OpenStudio & EnergyPlus

In most cases, critical (and many non-critical) OpenStudio anomalies will be caught by EnergyPlus at the start of a simulation. Standalone applications (e.g. _Apply Measures Now_) or [SDK](https://openstudio-sdk-documentation.s3.amazonaws.com/index.html)-based iterative solutions can't rely on EnergyPlus to catch such errors - and somehow warn users of potentially invalid results. This Ruby module provides developers a means to log warnings, as well as non-fatal & fatal errors, that may eventually put OpenStudio's (or EnergyPlus') internal processes at risk. Developers are free to decide how to harness __oslg__ as they see fit, e.g. output logged WARNING messages to the OpenStudio _runner_, while writing out DEBUG messages to a bug report file.

### Recommended use

As a Ruby module, it's best to access __oslg__ by _extending_ a measure module or class:

```
module Modu
  extend OSlg
  ...
end
```

Ordered __oslg__ levels (or CONSTANTS), from benign to severe:

```
DEBUG
INFO
WARN
ERROR
FATAL
```

DEBUG messages aren't benign at all, but are less informative for the typical Measure user.

Initially, __oslg__ sets 2x internal variable states: `level` (INFO) and `status` (< DEBUG). The variable `level` is a user-set threshold below which less severe logs (e.g. DEBUG) are ignored. For instance, if `level` were _reset_ to DEBUG (e.g. `Modu.reset(Modu::DEBUG)`), then all DEBUG messages would also be logged. The variable `status` is reset with each new log entry if the latter's log level is more severe than its predecessor (e.g. `status == Modu::FATAL` if there is a single log entry registered as FATAL). To check the curent __oslg__ `status` (true or false):  

```
Modu.debug?
Modu.warn?
Modu.error?
Modu.fatal?
```

It's sometimes not a bad idea to restart with a _clean_ slate within iterative loops. This flushes out all previous logs and resets `level` (INFO) and `status` (< DEBUG) - use with caution!

```
Modu.clean!
```

EnergyPlus will run with, e.g. out-of-range material or fluid properties, while logging ERROR messages in the process. It remains up to users to decide what to do with simulation results. We recommend something similar with __oslg__. For instance, we suggest logging as __FATAL__ any error that should halt measure processes and prevent OpenStudio from launching an EnergyPlus simulation. This could be missing or poorly-defined OpenStudio files.

```
Modu.log(Modu::FATAL, "Missing input JSON file")
```

Consider logging non-fatal __ERROR__ messages when encountering invalid OpenStudio file entries, i.e. well-defined, yet invalid vis-à-vis EnergyPlus limitations. The invalid object could be simply ignored, while the measure pursues its (otherwise valid) calculations ... with OpenStudio ultimately launching an EnergyPlus simulation. If a simulation indeed ran (ultimately a go/no-go decision made by the EnergyPlus simulation engine), it would be up to users to decide if simulation results were valid or useful, given the context - maybe based on __oslg__ logged messages. In short, non-fatal ERROR logs should ideally point to bad input users can fix.

```
Modu.log(Modu::ERROR, "Measure won't process MASSLESS materials")
```

A __WARNING__ could be triggered from inherit limitations of the underlying measure scope or methodology (something users may have little knowledge of beforehand). For instance, surfaces the size of dinner plates are often artifacts of poor 3D model design. It's usually not a good idea to have such small surfaces in an OpenStudio model, but neither OpenStudio nor EnergyPlus will necessarily warn users of such occurrences. It's up to users to decide on the suitable course of action.

```
Modu.log(Modu::WARN, "Surface area < 100cm2")
```

There's also the possibility of logging __INFO__-rmative messages for users, e.g. the final state of a measure variable before exiting.

```
Modu.log(Modu::INFO, "Envelope compliant to prescriptive requirements")
```

Finally, a number of sanity checks are likely warranted to ensure Ruby doesn't crash (e.g., invalid access to uninitialized variables), especially for lower-level functions. We suggest implementing safe fallbacks when this occurs, but __DEBUG__ errors could nonetheless be triggered to signal a bug.

```
Modu.log(Modu::DEBUG, "Hash? expecting Array (method)")
```

All log entries are stored in a single Ruby _Array_, with each individual log entry as a Ruby _Hash_ with 2x _keys_ ```:level``` and ```:message```, e.g.:

```
Modu.logs.each do |log|
  puts "Uh-oh: #{log[:message]}" if log[:level] > Modu::INFO
end
```

These logs can be first _mapped_ to other structures (then edited), depending on output targets.

### Preset log templates

Typically, developers would first catch bad input, log an error message and possibly exit by returning a variable (e.g. __false__, __nil__), e.g.:  

```
unless var.is_a?(Array)
  Modu.log(Modu::DEBUG, "#{var.class}? expecting Array (method)")
  return false
end
```

The following are compact, one-liner __oslg__ methods that _log & return_ in one go. These are for some of the most common checks OpenStudio SDK Ruby developers are likely to need. These methods require _valid_ arguments for __oslg__ to actually log. Although often expecting strings as arguments, the methods will try to convert other types to strings (e.g. classes, numbers, even entire arrays) if possible.

 ---

__invalid__: for logging  e.g. uninitialized or nilled objects:

```
return Modu.invalid("area", "sum", 0, Modu::ERROR, false) unless area
```

This logs an ERROR message informing readers that an invalid object, 'area', was caught while running method 'sum', and then exits by returning _false_. The logged message would be:

```
"Invalid 'area' (sum)"
```

The 3rd argument (e.g. _0_) is ignored unless `> 0` - a useful option when asserting method arguments:

```
def sum(areas, units)
  return Modu.invalid("areas", "sum", 1) unless areas
  return Modu.invalid("units", "sum", 2) unless units
  ...
end
```

... would generate the following if both `areas` and `units` arguments were nilled:
```
"Invalid 'areas' arg #1 (sum)"
"Invalid 'units' arg #2 (sum)"
```

The first 2x __invalid__ method arguments (faulty object ID, calling method ID) are required. The remaining 3x arguments are optional; in such cases, __invalid__ `level` defaults to DEBUG, and __invalid__ returns _nil_).

---

__mismatch__: for logging incompatible instances vs classes:

```
return Modu.mismatch("areas", areas, Array, "sum") unless areas.is_a?(Array)
```

If 'areas' were a _String_, __mismatch__ would generate the following DEBUG log message (before returning _nil_):

```
"'areas' String? expecting Array (sum)"
```

These 4x __mismatch__ arguments are required (an object ID, a valid Ruby object, the mismatched Ruby class, and the calling method ID). As a safeguard, __oslg__ will NOT log a _mismatch_ if the object is an actual instance of the class. As with __invalid__, there are 2x optional _terminal_ arguments, e.g. `Modu::ERROR, false)`.

---

__hashkey__: for logging missing _Hash_ keys:

```
return Modu.hashkey("faces", faces, :area, "sum") unless faces.key?(:area)
```

If the _Hash_ `faces` does not hold `:area` as one of its keys, then __mismatch__ would generate the following DEBUG log message (before returning _nil_):

```
"'faces' Hash: no key 'area' (sum)"
```

Similar to __mismatch__, the method __hashkey__ requires 4x arguments (a _Hash_ ID, a valid Ruby _Hash_, the missing _key_, and the calling method ID). There are also 2x optional _terminal_ arguments, e.g. `Modu::ERROR, false)`.

---

__empty__: for logging empty _Enumerable_ (e.g. _Array_, _Hash_) instances or uninitialized boost optionals (e.g. uninitialized _ThermalZone_ object of an _OpenStudio Space_):

```
return Modu.empty("faces", "sum", Modu::ERROR, false) if faces.empty?
```

An empty `faces` _Hash_ would generate the following ERROR log message (before returning _false_):

```
"Empty 'faces' (sum)"
```

Again, the first 2x arguments are required; the last 2x are optional.

---

__zero__: for logging zero'ed (or nearly-zero'ed) values:

```
Modu.zero("area", "sum", Modu::FATAL, false) if area.zero?
Modu.zero("area", "sum", Modu::FATAL, false) if area.abs < TOL
```
... generating the following FATAL log message (before returning _false_):

```
"'area' ~zero (sum)"
"'area' ~zero (sum)"
```

And again, the first 2x arguments are required; the last 2x are optional.

---

__negative__: for logging negative (< 0) values:

```
Modu.negative("area", "sum", Modu::FATAL, false) if area < 0
```
... generating this FATAL log message (before returning _false_):

```
"'area' negative (sum)"
```

You guessed it: the first 2x arguments are required; the last 2x as optionals.
