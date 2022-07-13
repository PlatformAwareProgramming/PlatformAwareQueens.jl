module PlatformAwareQueens

using PlatformAware

include("queens_serial.jl")
include("queens_multicore.jl")
include("queens_gpu.jl")
include("queens_multigpu.jl")
include("queens_cpugpu.jl")
include("queens_cluster.jl")
include("queens.jl")

end
