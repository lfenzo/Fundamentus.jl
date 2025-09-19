# Fundamentus.jl

Fundamentus.jl is a Julia package that provides programmatic access to Brazilian stock market data from the [Fundamentus website](https://www.fundamentus.com.br/).

With this package, you can easily retrieve structured data such as:
- Fundamental indicators: valuation ratios, liquidity measures, and balance sheet information.
- Dividend history: detailed records of dividend payments over time.
- Company press releases: official communications published by listed companies.
- Material facts: legally required disclosures (“fatos relevantes”) from FIIs.

Data is retrieved and returned as [DataFrame](https://github.com/JuliaData/DataFrames.jl) objects, for convenient analysis and manipulation in Julia. Repeated queries are automatically cached to improve performance.

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

```raw
julia> using Fundamentus

julia> fiis()
528×14 DataFrame
 Row │ papel   name                               segmento             cotacao   ffo_yield  div_yield  p_vp     market_cap  liq       n_properties  m2_price  m2_rent  cap_rate  avg_vacancy 
     │ String  String                             String               Float64   Float64    Float64    Float64  Float64     Int64     Int64         Float64   Float64  Float64   Float64     
─────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ AAZQ11  AZ QUEST SOLE FUNDO DE INVESTIME…  Outros                   7.59     0.1381     0.1589     0.88  1.82443e8     429454             0      0.0      0.0     0.0          0.0
   2 │ ABCP11  GRAND PLAZA SHOPPING FUNDO DE IN…  Shoppings               81.0      0.0979     0.0936     0.76  3.81436e8      86043             1   5354.89   655.94    0.1225       0.0268
   3 │ AEFI11  FUNDO DE INVESTIMENTO IMOBILIÁRI…  Outros                 174.9      0.0855     0.0        1.75  4.11893e8          0             0      0.0      0.0     0.0          0.0
   4 │ AFCR11  CARTESIA RECEBÍVEIS IMOBILIÁRIOS…  Multicategoria         103.15     0.1261     0.0        1.07  4.98867e8          0             0      0.0      0.0     0.0          0.0
   5 │ AFHF11  AF INVEST REAL ESTATE MULTIESTRA…  Outros                  10.08     0.0        0.0245     1.0   5.04e7         92574             0      0.0      0.0     0.0          0.0
   6 │ AFHI11  AF INVEST CRI FUNDO DE INVESTIME…  Multicategoria          92.65     0.1247     0.1261     0.98  4.22078e8     793004             0      0.0      0.0     0.0          0.0
   7 │ AFOF11  ALIANZA MULTIESTRATÉGIA FUNDO DE…  Títulos e Val. Mob.     91.6      0.0082     0.0       12.28  1.39054e9          0             0      0.0      0.0     0.0          0.0
   8 │ AGCX11  RIO BRAVO RENDA VAREJO FUNDO DE …  Varejo                1235.5      0.0053     0.0       11.57  1.92915e10         0            82  63941.3    468.9     0.0073       0.0386
...
```

!!! note
    Function and column names are kept in Portuguese to remain consistent with the terminology used on the Fundamentus website.
    All documentation and usage examples, however, are provided in English. This may change in the
    future depending on feedback.
