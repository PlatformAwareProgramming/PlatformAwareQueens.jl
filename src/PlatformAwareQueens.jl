module PlatformAwareQueens

using PlatformAware
using CUDA
using StaticArrays

CUDA.@check @ccall CUDA.libcudart().cudaDeviceSetLimit(CUDA.cudaLimitMallocHeapSize::CUDA.cudaLimit, 100000000::Csize_t)::CUDA.cudaError_t

include("queens_base.jl")
include("queens_serial.jl")
include("queens_mcore.jl")
include("queens_sgpu.jl")
include("queens_mgpu.jl")
include("queens_mcore_mgpu.jl")
include("queens_cluster.jl")
include("queens.jl")

end
