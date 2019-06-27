# EnergyModels

<!-- [![Build Status](https://travis-ci.org/coroa/EnergyModels.jl.svg?branch=master)](https://travis-ci.org/coroa/EnergyModels.jl) -->

<!-- [![Coverage Status](https://coveralls.io/repos/coroa/EnergyModels.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/coroa/EnergyModels.jl?branch=master) -->

<!-- [![codecov.io](http://codecov.io/github/coroa/EnergyModels.jl/coverage.svg?branch=master)](http://codecov.io/github/coroa/EnergyModels.jl?branch=master) -->

EnergyModels is a free software toolbox for optimising modern power systems that include features such as conventional generators, variable wind and solar generation, storage units, coupling to other energy sectors, and mixed alternating and direct current networks. EnergyModels is explicitly designed to be memory proficient for large networks and long time series, while keeping a clearly delineated and extensible model system.

This project has been developed by the Energy System Modelling group at the Institute for Automation and Applied Informatics at the Karlsruhe Institute of Technology. The current development is financed by the [PrototypeFund](https://prototypefund.de/project/energymodels/).

## Usage Outlook (WIP) ##

### Regular Use ###

```julia
jumpmodel = JuMP.direct_model(Gurobi.Optimizer())
model = EnergyModel("elec_s_45.nc", jumpmodel=jumpmodel)
build!(model)

print(jumpmodel)

optimize!(model)

print(model[Generator][:p_nom])

plot(sum(model[:onwind][:p], dim=1))
```

```julia
model_uc = EnergyModel(model, OperationalModel, Generator=>GeneratorCommitForm, StorageUnit=>StorageUnitUC)
build!(model, Gurobi.Optimizer())

```

# StructJuMP

