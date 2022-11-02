import Pkg; Pkg.activate(".")
using PlatformAwareQueens

function main(args)

        @info args

	v = parse(Int64,args[1])
	size = parse(Int64,args[2])
	i = parse(Int64,args[3])

	if (v < 0)
		@info "$i: structured"
		@time queens(size)
		@time queens(size)
        elseif (v == 1)
                @info "$i: ad-hoc / serial"
                @time PlatformAwareQueens.queens_serial(size)
                @time PlatformAwareQueens.queens_serial(size)
        elseif (v == 2)
                @info "$i: ad-hoc / mcore"
                @time PlatformAwareQueens.queens_mcore(size)
                @time PlatformAwareQueens.queens_mcore(size)	
	elseif (v == 3)
                @info "$i: ad-hoc / sgpu"
                @time PlatformAwareQueens.queens_sgpu(size)
                @time PlatformAwareQueens.queens_sgpu(size)
        elseif (v == 4)
                @info "$i: ad-hoc / mgpu"
                @time PlatformAwareQueens.queens_mgpu(size)
                @time PlatformAwareQueens.queens_mgpu(size)
        elseif (v == 5)
                @info "$i: ad-hoc / mcore-mgpu"
                @time PlatformAwareQueens.queens_mgpu_mcore(size)
                @time PlatformAwareQueens.queens_mgpu_mcore(size)	
	else
		@info "wrong selection"
	end
end

main(ARGS)

