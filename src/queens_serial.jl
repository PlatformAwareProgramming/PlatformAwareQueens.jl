# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------


@platform default function queens(size)
    
   @time queens_serial(size+1)

end

function queens_serial(size)

	__VOID__     = 0
	__VISITED__    = 1
	__N_VISITED__   = 0

	depth = 1
	tree_size = 0
	number_of_solutions = 0
	local_visited = zeros(Int64,size)
	local_permutation = zeros(Int64,size)

	while true
		local_permutation[depth] = local_permutation[depth]+1

		if local_permutation[depth] == (size+1)
			local_permutation[depth] = __VOID__
		else
			if (local_visited[local_permutation[depth]] == 0 && queens_is_valid_configuration(local_permutation,depth))

				local_visited[local_permutation[depth]] = __VISITED__
				depth +=1
				tree_size+=1

				if depth == size+1 ##complete solution -- full, feasible and valid solution
					number_of_solutions+=1
				else
					continue
				end
			else
				continue
			end #elif
		end

		depth -= 1
		local_visited[local_permutation[depth]] = __N_VISITED__

		if depth < 2
			break
		end #if depth<2

	end

    return (number_of_solutions, tree_size) 
end #queens serial
