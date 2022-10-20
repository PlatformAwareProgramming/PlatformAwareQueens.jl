# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------


@platform default function queens(size)
    
   @time queens_serial(Val(size+1))

   println("teste")
end

function queens_serial(::Val{size}) where size

	#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'
	println("Starting N-Queens of size ", size-1)

	local_visited = zeros(Int64,size)
	local_permutation = zeros(Int64,size)

	number_of_solutions, tree_size = queens_tree_explorer(size, 1, 0, local_visited, local_permutation)

	println("Number of solutions: $(number_of_solutions)")
	println("Tree size: $(tree_size)")

end #queens serial