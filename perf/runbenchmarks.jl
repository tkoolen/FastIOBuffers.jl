module FastIOBuffersBenchmarks

using Compat
using Compat.Random
using BenchmarkTools
using FastIOBuffers

const N = 1000

suite = BenchmarkGroup()

suite["write"] = BenchmarkGroup()
suite["write"]["Float64"] = @benchmarkable write(buf, x) evals = N setup = begin
    x = rand(Float64)
    buf = FastWriteBuffer(Vector{UInt8}(undef, N * Core.sizeof(x)))
end
suite["write"]["String"] = @benchmarkable write(buf, x) evals = N setup = begin
    x = randstring(8)
    buf = FastWriteBuffer(Vector{UInt8}(undef, N * sizeof(x)))
end

overhead = BenchmarkTools.estimate_overhead()
results = run(suite, verbose=true, overhead=overhead, gctrial=false)
for result in results["write"]
    println("$(first(result)):")
    display(last(result))
    println()
end

end
