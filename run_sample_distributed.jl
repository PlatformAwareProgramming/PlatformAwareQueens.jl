@everywhere PATH_REPO = get(ENV,"PATH_REPO",".")
@everywhere begin import Pkg; Pkg.activate(PATH_REPO) end
@everywhere using PlatformAwareQueens

function main(args)

        @info args

	v = parse(Int64, args[1])
	size = parse(Int64, args[2])
	i = parse(Int64, args[3])

	if (v == 0)
		@info "$i: structured"
		@time queens(size)
		@time queens(size)
    elseif (v == 1)
        @info "$i: ad-hoc / distributed"
        @time PlatformAwareQueens.queens_distributed(size)
        @time PlatformAwareQueens.queens_distributed(size)	
	else
		@info "wrong selection"
	end
end

main(ARGS)

