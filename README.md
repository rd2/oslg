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

In most cases, critical (and many non-critical) OpenStudio anomalies will be caught by EnergyPlus at the start of a simulation. For iterative solutions or _standalone_ cases (e.g. _Apply Measures Now_), measures can't rely on EnergyPlus to catch such errors - and somehow warn users of potentially invalid results. This Ruby module is designed to log warnings, as well as non-fatal & fatal errors, that may put its parent OpenStudio (or EnergyPlus) measures' internal processes at risk. The presence of FATAL, ERROR or WARNING log entries should ideally be interpreted as something to look into and/or remediate. Developers are free to decide how to harness __oslg__ as they see fit, e.g. output logged warnings to the _runner_, while writing out DEBUG messages to file.

EnergyPlus will run with e.g. out-of-range material or fluid properties. This triggers an ERROR in EnergyPlus, yet simulations proceed regardless - it's up to users to decide what to do with simulation results. We recommend something similar with __oslg__ - but it remains up to each developer.

### Recommended use

As a Ruby module, it's best to add __oslg__ by _extending_ a measure module or class.  

```
module Modu
  extend OSlg
  ...
end
```

Not a bad idea to start with a _clean_ slate (quite useful with iterative solutions) - use with caution!

```
Modu.clean!
```


We suggest logging as __FATAL__ any error that should halt measure processes and prevent OpenStudio from launching an EnergyPlus simulation. This could be missing or poorly-defined OpenStudio files.

```
Modu.log(Modu::FATAL, "Missing input JSON file")
```

Consider logging non-fatal __ERROR__ messages when encountering invalid OpenStudio file entries, e.g. well defined, yet invalid vis-à-vis EnergyPlus limitations. The invalid object could be simply ignored, while the measure pursues its (otherwise valid) calculations ... with OpenStudio ultimately launching an EnergyPlus simulation. If a simulation indeed ran (ultimately a go/no-go decision taken by the EnergyPlus simulation engine), it would be up to users to decide if the simulation results were valid or useful, given the context (maybe based on __oslg__ logged messages). In short, non-fatal ERROR logs should point to bad input users can fix.

```
Modu.log(Modu::ERROR, "Measure won't process MASSLESS materials")
```

A __WARNING__ could be triggered from inherit limitations of the underlying measure scope or methodology (something the user has limited control over beforehand). For instance, a surface the size of a dinner plate is often an artifact of poor 3D model design. It's usually not a good idea to have such small surfaces in an OpenStudio model, but neither OpenStudio nor EnergyPlus will necessarily warn users of such occurrences. It's up to users to decide on the suitable course of action.

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
exit
```

Log entries are stored in an Array, with each individual log entry as a Hash with 2x _keys_ ```:level``` and ```:message```, e.g.:

```
Modu.logs.each do |log|
  puts "Uh-oh: #{log[:message]}" if log[:level] > Modu::INFO
end
```

These logs can be first _mapped_ to other structures (then edited), depending on output targets.
