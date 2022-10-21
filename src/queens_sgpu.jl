# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform aware function queens({accelerator_count::(@atleast 1), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                 size)
    # CUDA code for a single device follows ...
	cutoff_depth = 5
	__BLOCK_SIZE_ = 128
	@time queens_sgpu_caller(Val(size+1), Val(cutoff_depth+1), Val(__BLOCK_SIZE_))
end



function queens_sgpu_caller(::Val{size}, ::Val{cutoff_depth}, ::Val{__BLOCK_SIZE_}) where {size, cutoff_depth, __BLOCK_SIZE_}

	#partial search -- generate some feasible valid and incomplete solutions
	(subproblems, number_of_subproblems, partial_tree_size) = @time queens_partial_search!(Val(size), Val(cutoff_depth))
	#end of the partial search

	number_of_solutions, partial_tree_size = queens_gpu_caller(size, cutoff_depth, __BLOCK_SIZE_, number_of_subproblems, 1, subproblems)

	println("\n###########################")
	println("N-Queens size: ", size-1, "\n###########################\n" ,"\nNumber of sols: ",number_of_solutions, "\nTree size: " ,partial_tree_size,"\n\n")
end #caller














#