module FastIOBuffers

export FastWriteBuffer

using Compat

struct FastWriteBuffer <: IO
    data::Vector{UInt8}
    position::Base.RefValue{Int}
end

FastWriteBuffer(data::Vector{UInt8}) = FastWriteBuffer(data, Ref(0))
FastWriteBuffer() = FastWriteBuffer(Vector{UInt8}())

@inline function ensureroom!(buf::FastWriteBuffer, n::Integer)
    resize!(buf.data, buf.position[] + n)
end

function Base.take!(buf::FastWriteBuffer)
    resize!(buf.data, buf.position[])
    buf.position[] = 0
    buf.data
end

@inline function Base.unsafe_write(buf::FastWriteBuffer, p::Ptr{UInt8}, n::UInt)
    ensureroom!(buf, n)
    unsafe_copyto!(pointer(buf.data, buf.position[] + 1), p, n)
    buf.position[] += n
    Int(n)
end

Base.@propagate_inbounds function Base.write(buf::FastWriteBuffer, x::UInt8)
    ensureroom!(buf, 1)
    position = buf.position[] += 1
    buf.data[position] = x
    1
end

Base.@propagate_inbounds Base.write(buf::FastWriteBuffer, x::Int8) = write(buf, reinterpret(UInt8, x))

@inline function Base.write(
            buf::FastWriteBuffer,
            x::Union{Int16,UInt16,Int32,UInt32,Int64,UInt64,Int128,UInt128}) # TODO: more?
    n = Core.sizeof(x)
    ensureroom!(buf, n)
    position = buf.position[]
    @inbounds for i = Base.OneTo(n) # LLVM unrolls this loop on Julia 0.6.4
        position += 1
        buf.data[position] = x % UInt8
        x = x >>> 8
    end
    buf.position[] = position
    n
end

@inline Base.write(buf::FastWriteBuffer, x::Union{Float16, Float32, Float64}) = write(buf, reinterpret(Unsigned, x))

Base.eof(buf::FastWriteBuffer) = true

end # module
