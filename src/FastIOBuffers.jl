module FastIOBuffers

export
    FastWriteBuffer,
    FastReadBuffer

export
    setdata!

using Compat

include("fastwritebuffer.jl")
include("fastreadbuffer.jl")

end # module
