# oslog

A logger module for [OpenStudio](https://openstudio-sdk-documentation.s3.amazonaws.com/index.html) [Measure](https://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/) developers who wish to select what gets logged to which target (e.g. OpenStudio _runner_ vs custom JSON file).

### OpenStudio & EnergyPlus

In most cases, critical (and many non-critical) OpenStudio anomalies will be caught by EnergyPlus at the start of a simulation. For _standalone_ cases (e.g. _Apply Measures Now_), measures can't rely on EnergyPlus to catch such errors - and somehow warn users of potentially invalid results. This Ruby module is designed to minimally log warnings, as well as non-fatal & fatal errors, that may put its parent OpenStudio (or EnergyPlus) measures' internal processes at risk. The presence of FATAL, ERROR or WARNING log entries should be interpreted as something to look into and/or remediate.

EnergyPlus will run with e.g. out-of-range material or fluid properties. This triggers an ERROR in EnergyPlus, yet EnergyPlus will often run the simulation regardless. It's up to users to decide what to do with simulation results. We recommend something similar here, but it remains up to each developer.

### Recommended use

We suggest logging as __FATAL__ any error that should halt measure processes and prevent OpenStudio from launching an EnergyPlus simulation. This could be missing or poorly-defined OpenStudio files.

The vast majority of checks would likely log non-fatal __ERROR__ messages when e.g. encountering invalid OpenStudio file entries (well defined, yet invalid vis-à-vis EnergyPlus limitations). In such cases, the object could be simply ignored. The measure could be allowed to pursue its (otherwise valid) calculations, and OpenStudio would ultimately launch an EnergyPlus simulation. If a simulation indeed ran (ultimately a go/no-go decision taken by the EnergyPlus simulation engine), it would be up to users to decide if the simulation results were valid or useful, given the context. In short, non-fatal ERROR logs should point to bad input a user can fix.

A __WARNING__ should be mainly triggered from inherit limitations of the underlying measure scope or methodology (something the user has limited control over beforehand). For instance, a surface the size of a dinner plate is often an artifact of poor 3D model design. It's usually not a good idea to have such small surfaces in an OpenStudio model, but neither OpenStudio nor EnergyPlus will necessarily warn users of such occurrences. It's up to users to decide on the suitable course of action.

There's also the possibility of logging __INFO__-rmative messages for users e.g., the final state of a measure variable before exiting.

Finally, a number of sanity checks are likely warranted to ensure Ruby doesn't crash (e.g., invalid access to uninitialized variables), especially for lower-level functions. There are usually safe fallbacks when this occurs, but __DEBUG__ errors could nonetheless be triggered. DEBUG errors are almost always signs of a bug - to be raised and fixed by measure developers).
