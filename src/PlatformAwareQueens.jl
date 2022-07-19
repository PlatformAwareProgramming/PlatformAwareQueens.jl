module PlatformAwareQueens

using PlatformAware

#PlatformAware.setplatform!(:processor_core_count, @just 1)

include("queens_base.jl")
include("queens_serial.jl")
include("queens_multicore.jl")
include("queens_gpu.jl")
include("queens_multigpu.jl")
include("queens_cpugpu.jl")
include("queens_cluster.jl")
include("queens.jl")

end
