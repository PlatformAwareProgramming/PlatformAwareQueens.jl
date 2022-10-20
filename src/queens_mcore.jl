# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------


@platform aware function queens({processor_core_count::(@atleast 2)}, size)

    num_threads = Threads.nthreads()
    cutoff_depth = 5

    @time queens_mcore_caller(Val(size+1), Val(cutoff_depth+1), Val(num_threads))

end




function queens_mcore_caller(::Val{size},::Val{cutoff_depth},::Val{num_threads}) where {size, cutoff_depth, num_threads}

	println("Starting MCORE N-Queens of size $(size-1)")

	#partial search -- generate some feasible valid and incomplete solutions
	(subproblems, number_of_subproblems, partial_tree_size) = @time queens_partial_search!(Val(size), Val(cutoff_depth))

	println(number_of_subproblems)

	number_of_solutions, tree_size = queens_mcore_caller(size, cutoff_depth, num_threads, number_of_subproblems, subproblems) 
	tree_size += partial_tree_size

	println("\n###########################")
	println("N-Queens size: $(size-1)")
	println("Number of threads: $(num_threads)")
	println("###########################") 
	println("Number of sols: $(number_of_solutions)") 
	println("Tree size: $tree_size")
end #caller


function queens_mcore_caller(size, cutoff_depth, num_threads, number_of_subproblems, subproblems) 

	thread_tree_size = zeros(Int64, num_threads)
	thread_num_sols  = zeros(Int64, num_threads)
	thread_load = fill(div(number_of_subproblems, num_threads), num_threads)
	stride = div(number_of_subproblems, num_threads)
	println(thread_load)
	thread_load[num_threads] += mod(number_of_subproblems, num_threads)

	@sync begin
		for ii in 0:(num_threads-1)

			println("LOOP $(string(ii))")
			local local_thread_id = ii
			local local_load = thread_load[local_thread_id+1]

			Threads.@spawn begin
				println("THREAD: $(string(local_thread_id)) has $(string(local_load)) iterations")
				for j in 1:local_load

					s = local_thread_id * stride + j

					(local_number_of_solutions, local_partial_tree_size) = queens_tree_explorer(size, cutoff_depth, 1, subproblems[s][1]#=.subproblem_is_visited=#, subproblems[s][2]#=.subproblem_partial_permutation=#)
					thread_tree_size[local_thread_id+1] += local_partial_tree_size
					thread_num_sols[local_thread_id+1]  += local_number_of_solutions
				end
			end

		end
	end
	mcore_number_of_solutions = sum(thread_num_sols)
	mcore_tree_size = sum(thread_tree_size)

	return mcore_number_of_solutions, mcore_tree_size

end #caller