# FastIOBuffers

[![Build Status](https://travis-ci.org/tkoolen/FastIOBuffers.jl.svg?branch=master)](https://travis-ci.org/tkoolen/FastIOBuffers.jl)
[![codecov.io](http://codecov.io/github/tkoolen/FastIOBuffers.jl/coverage.svg?branch=master)](http://codecov.io/github/tkoolen/FastIOBuffers.jl?branch=master)

FastIOBuffers aims to provide faster alternatives to `Base.IOBuffer`, which as of time of writing allocates memory even when e.g. a `Float64` is written to or read from it.

Currently, this package only provides `FastWriteBuffer`, which solves the allocation problem for the write use case. On 0.6.4:

```julia
using Compat, BenchmarkTools
N = 1000
@btime write(buf, x) evals = N setup = begin
    x = rand(Float64)
    buf = IOBuffer(Vector{UInt8}(undef, N * Core.sizeof(x)), false, true)
end
```

results in `39.338 ns (2 allocations: 32 bytes)`, while

```julia
using Compat, BenchmarkTools
using FastIOBuffers
N = 1000
@btime write(buf, x) evals = N setup = begin
    x = rand(Float64)
    buf = FastWriteBuffer(Vector{UInt8}(undef, N * Core.sizeof(x)))
end
```

results in `10.526 ns (0 allocations: 0 bytes)`
