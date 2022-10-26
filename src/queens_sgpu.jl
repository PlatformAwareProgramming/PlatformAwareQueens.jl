# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform aware function init_queens({accelerator_count::(@atleast 1), 
                                 	  accelerator_manufacturer::NVIDIA,
                                 	  accelerator_api::(@api CUDA)})
	nothing
end

@platform aware function queens({accelerator_count::(@atleast 1), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                 size)
	@time queens_sgpu(size)
end

function queens_sgpu(size)

	size += 1

	cutoff_depth = getCutoffDepth()

	(subproblems, number_of_subproblems, partial_tree_size) = @time queens_partial_search!(Val(size), cutoff_depth)

	number_of_solutions, tree_size = queens_gpu_caller(size, cutoff_depth, number_of_subproblems, 1, subproblems)

	return number_of_solutions, tree_size + partial_tree_size

end #caller














#