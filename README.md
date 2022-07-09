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

In most cases, critical (and many non-critical) OpenStudio anomalies will be caught by EnergyPlus at the start of a simulation. Standalone applications (e.g. _Apply Measures Now_) or [SDK](https://openstudio-sdk-documentation.s3.amazonaws.com/index.html)-based iterative solutions can't rely on EnergyPlus to catch such errors - and somehow warn users of potentially invalid results. This Ruby module provides developers a solution to log warnings, as well as non-fatal & fatal errors, that may eventually put OpenStudio (or EnergyPlus) internal processes at risk. Developers are free to decide how to harness __oslg__ as they see fit, e.g. output logged WARNING messages to the OpenStudio _runner_, while writing out DEBUG messages to a bug report file.

### Recommended use

As a Ruby module, it's best to add __oslg__ by _extending_ a measure module or class.

```
module Modu
  extend OSlg
  ...
end
```

Ordered __oslg__ levels (from benign to severe):

```
DEBUG
INFO
WARN
ERROR
FATAL
```

Initially, __oslg__ sets 2x internal variable states: __level__ (= INFO) and __status__ (< DEBUG). The variable __level__ is a threshold below which less severe logs (e.g. DEBUG) are ignored. For instance, if __level__ were reset to DEBUG (```Modu.set_level(Modu::DEBUG)```), then all DEBUG messages would also be logged. The variable __status__ is reset with each new log entry if the latter's log level is more severe than its predecessor (e.g. __status__ = FATAL if there is a single log entry registered as FATAL). To check the curent __status__ (true or false):  

```
Modu.debug?
Modu.warn?
Modu.error?
Modu.fatal?
```

Not a bad idea to start each instance with a _clean_ slate (quite useful with iterative solutions). This flushes out all previous logs and resets __level__ (= INFO) and __status__ (< DEBUG) - use with caution!

```
Modu.clean!
```

EnergyPlus will run with e.g. out-of-range material or fluid properties - while logging ERROR messages in the process. It remains up to users to decide what to do with simulation results. We recommend something similar with __oslg__ - but this is up to each developer. We suggest logging as __FATAL__ any error that should halt measure processes and prevent OpenStudio from launching an EnergyPlus simulation. This could be missing or poorly-defined OpenStudio files.

```
Modu.log(Modu::FATAL, "Missing input JSON file")
```

Consider logging non-fatal __ERROR__ messages when encountering invalid OpenStudio file entries, i.e. well-defined, yet invalid vis-à-vis EnergyPlus limitations. The invalid object could be simply ignored, while the measure pursues its (otherwise valid) calculations ... with OpenStudio ultimately launching an EnergyPlus simulation. If a simulation indeed ran (ultimately a go/no-go decision made by the EnergyPlus simulation engine), it would be up to users to decide if simulation results were valid or useful, given the context (maybe based on __oslg__ logged messages). In short, non-fatal ERROR logs should ideally point to bad input users can fix.

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

Finally, a number of sanity checks are likely warranted to ensure Ruby doesn't crash (e.g., invalid access to uninitialized variables), especially for lower-level functions. There are usually safe fallbacks when this occurs, but __DEBUG__ errors could nonetheless be triggered to signal a bug.

```
Modu.log(Modu::DEBUG, "Method argument is a Hash, expected an Array - this is a bug!")
```

All log entries are stored in a single Ruby Array: each individual log entry as a Ruby Hash with 2x _keys_ ```:level``` and ```:message```, e.g.:

```
Modu.logs.each do |log|
  puts "Uh-oh: #{log[:message]}" if log[:level] > Modu::INFO
end
```

These logs can be first _mapped_ to other structures (then edited), depending on output targets.
