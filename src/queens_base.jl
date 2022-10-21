
#verifies whether a given solution/incomplete solution is feasible
function queens_is_valid_configuration(board, roll)
    #heron: why can board be a Number ? In the code, it is always accessed as an array.
    
    for i=2:roll-1
        if (board[i] == board[roll])
            return false
        end
    end

    ld = board[roll]
    rd = board[roll]

    for j=(roll-1):-1:2
        ld -= 1
        rd += 1
        if (board[j] == ld || board[j] == rd)
            return false
        end
    end

    return true
end ##queens_is_valid_conf




macro tree_explorer(name, depth_initial, depth_solution, depth_break, initial_solution, action_solution, returned_solution) 

	:(function $name(size, cutoff_depth, local_visited, local_permutation)

		@inbounds begin
			__VOID__     = 0
			__VISITED__    = 1
			__N_VISITED__   = 0

			depth = $depth_initial
			tree_size = 0
			$initial_solution	

			while true
				#%println(local_cycle)

				local_permutation[depth] = local_permutation[depth] + 1

				if local_permutation[depth] == (size+1)
					local_permutation[depth] = __VOID__
				else
					if (local_visited[local_permutation[depth]] == 0 && queens_is_valid_configuration(local_permutation, depth))

						local_visited[local_permutation[depth]] = __VISITED__
						depth +=1
						tree_size+=1

						if depth == $depth_solution ##complete solution -- full, feasible and valid solution
							$action_solution 
							#println(local_visited, " ", local_permutation)
						else
							continue
						end
					else
						continue
					end #elif
				end

				depth -= 1
				local_visited[local_permutation[depth]] = __N_VISITED__

				if depth < $depth_break
					break
				end #if depth<2
			end
		end

		return $returned_solution, tree_size
	end)
end

@tree_explorer queens_partial_search 1 cutoff_depth+1 2 subproblems_pool=[] push!(subproblems_pool, (copy(local_visited), copy(local_permutation))) subproblems_pool
@tree_explorer queens_tree_explorer_serial 1 size+1 2 number_of_solutions=0 number_of_solutions+=1 number_of_solutions
@tree_explorer queens_tree_explorer_parallel cutoff_depth+1 size+1 cutoff_depth+1 number_of_solutions=0  number_of_solutions+=1 number_of_solutions

function queens_partial_search!(::Val{size}, ::Val{cutoff_depth}) where {size, cutoff_depth}

	#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'
	println("Starting N-Queens of size $(size-1)")
	println("Partial search until cutoff $(cutoff_depth)")

	subproblems_pool = []

	local_visited = zeros(Int64,size)
	local_permutation = zeros(Int64,size)

	subproblems_pool, tree_size = queens_partial_search(size, cutoff_depth, local_visited, local_permutation)

	number_of_subproblems = length(subproblems_pool)

	return (subproblems_pool, number_of_subproblems, tree_size)

end #queens partial


function gpu_queens_tree_explorer!(::Val{size}, ::Val{cutoff_depth}, ::Val{number_of_subproblems}, 
                                   permutation_d, 
                                   controls_d, 
                                   tree_size_d, 
                                   number_of_solutions_d, 
                                   indexes_d) where {size, cutoff_depth, number_of_subproblems}
	@inbounds begin

		#obs: because the vector begins with 1 I need to use size+1 for N-Queens of size 'size'
		index =  (blockIdx().x - 1) * blockDim().x + threadIdx().x

		if index<=number_of_subproblems
			indexes_d[index] = index
			stride_c = (index-1)*cutoff_depth

			local_visited     = MArray{Tuple{size+1},Int64}(undef)
			local_permutation = MArray{Tuple{size+1},Int64}(undef)

			local_visited     .= 0
			local_permutation .= 0

		#@OBS> so... I allocate on CPU memory for the cuda kernel...
		### then I get the values on GPU.
			for j in 1:cutoff_depth
				local_visited[j] = controls_d[stride_c+j]
				local_permutation[j] = permutation_d[stride_c+j]	
			end

			number_of_solutions, tree_size = queens_tree_explorer_parallel(size, cutoff_depth, local_visited, local_permutation)

			number_of_solutions_d[index] = number_of_solutions
			tree_size_d[index] = tree_size
		end #if
	end
return

end #queens tree explorer


function queens_gpu_subproblems_organizer!(cutoff_depth, num_subproblems, prefixes, controls, starting_point, subproblems)

	for sub in 0:num_subproblems-1
		stride = sub*cutoff_depth
		for j in 1:cutoff_depth
			prefixes[stride+j] = subproblems[sub+starting_point][2][j] # subproblem_partial_permutation
			controls[stride+j] = subproblems[sub+starting_point][1][j] # subproblem_is_visited
		end
	end

end


function queens_gpu_caller(size, cutoff_depth, __BLOCK_SIZE_, number_of_subproblems, starting_point, subproblems)

	print("Starting single-GPU-based N-Queens of size ", size-1, " Device: ",  )
	println(size-1)
		
	number_of_solutions = 0
	partial_tree_size = 0
	#metrics.number_of_solutions = 0

	indexes_h = subpermutation_h = zeros(Int32, number_of_subproblems)
	subpermutation_h = zeros(Int64, cutoff_depth*number_of_subproblems)
	controls_h = zeros(Int64, cutoff_depth*number_of_subproblems)
	number_of_solutions_h = zeros(Int64, number_of_subproblems)
	tree_size_h = zeros(Int64, number_of_subproblems)

	queens_gpu_subproblems_organizer!(cutoff_depth, number_of_subproblems, subpermutation_h, controls_h, starting_point, subproblems)

	#### the subpermutation_d is the memory allocated to keep all subpermutations and the control vectors...
	##### Maybe I could have done it in a smarter way...
	subpermutation_d      = CuArray{Int64}(undef,  cutoff_depth*number_of_subproblems)
	controls_d            = CuArray{Int64}(undef,  cutoff_depth*number_of_subproblems)

	#### Tree size and number of solutions is to get the metrics from the search.
	indexes_d = CUDA.zeros(Int32,number_of_subproblems)
	number_of_solutions_d = CUDA.zeros(Int64, number_of_subproblems)
	tree_size_d = CUDA.zeros(Int64,number_of_subproblems)

	# copy from the CPU to the GPU
	copyto!(subpermutation_d, subpermutation_h)
	# copy from the CPU to the GPU
	copyto!(controls_d, controls_h)

	num_blocks = ceil(Int, number_of_subproblems/__BLOCK_SIZE_)

	@info "Number of subproblems:", number_of_subproblems, " - Number of blocks:  ", num_blocks

    @cuda threads=__BLOCK_SIZE_ blocks=num_blocks gpu_queens_tree_explorer!(Val(size),Val(cutoff_depth), Val(number_of_subproblems), subpermutation_d, controls_d, tree_size_d, number_of_solutions_d, indexes_d)

    #from de gpu to the cpu
	copyto!(number_of_solutions_h, number_of_solutions_d)
	#from de gpu to the cpu
	copyto!(tree_size_h, tree_size_d)

	copyto!(indexes_h, indexes_d)
	number_of_solutions = sum(number_of_solutions_h)
	partial_tree_size += sum(tree_size_h)

	#print("\n\n")
	#print(indexes_h)

	return (number_of_solutions, partial_tree_size)
end #caller

