# Agent Based programing in Julia
The AgetnBased.jl package aims to help fast designing and simulation of Agent Based models.

The following dynamical methods can be implemented in the model:
 - ODEs
 - SDEs with Ito prescription

Additionally, the package incorporates special functions as: 
 - Division events
 - Removal events
 - Randomly selected pairwise interactions

The created models can run the simulations both in CPU and CUDA GPU thanks to the [CUDA.jl](https://juliagpu.gitlab.io/CUDA.jl/tutorials/introduction/). The possibility to run in the simulations in GPU makes it possible to run in a resonable time simulations with a huge number of particles.

## Installation
Two options to install de package.

```julia
Pkg.add("AgentModel")
```

or clone it from the repository. 

## Requirements and Optional Modules

The current version of AgentModel.jl requires the following packages:

Random >= 1.5
Distributions >= 1.6

and in the case that the simulations want to be performed in CUDA, additionall