# Fundamentus.jl

Fundamentus.jl is a Julia package that provides programmatic access to Brazilian stock market data from the [Fundamentus website](https://www.fundamentus.com.br/).
Data includes fundamental indicators, dividend history, performance metrics, press releases, etc.

Data is retrieved and returned as [DataFrame]() objects, for convenient analysis and manipulation in Julia. Repeated queries are automatically cached to improve performance.

## Installation

Fundamentus.jl can be installed from the Julia General Package Registry:

```julia
using Pkg; Pkg.add("Fundamentus")
```

## Usage

The API is organized into two main groups of functions:
- `acao_*`: retrieve data related to Brazilian stocks (*Ações*).
- `fii_*`: retrieve data related to Brazilian Real Estate Investment Funds (*FIIs*).

Most functions take a single argument: the `ticker` symbol of the stock or fund you want to query.
For a full list of available functions, check the [API Reference](./api_reference.md).

```@repl
using Fundamentus
first(acao_proventos("ITUB4"), 5)  # Fetch dividend history for ITUB4
```

!!! note
    Function and column names are kept in Portuguese to remain consistent with the terminology used on the Fundamentus website.
    All documentation and usage examples, however, are provided in English.
