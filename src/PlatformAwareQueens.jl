module PlatformAwareQueens

using PlatformAware
using CUDA
using StaticArrays

PlatformAware.setplatform!(:processor_core_count, @just 1)

include("queens_base.jl")
include("queens_serial.jl")
include("queens_mcore.jl")
include("queens_sgpu.jl")
include("queens_mgpu.jl")
include("queens_mcore_mgpu.jl")
include("queens_cluster.jl")
include("queens.jl")

end
