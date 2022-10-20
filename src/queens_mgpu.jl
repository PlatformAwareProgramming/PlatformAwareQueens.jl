# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform aware function queens({accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                size)
    # CUDA code for a multiple devices follows ...
	cutoff_depth = 5
	__BLOCK_SIZE_ = 128
	num_gpus = length(CUDA.devices())

	@time queens_mgpu_caller(Val(size+1), Val(cutoff_depth+1), Val(__BLOCK_SIZE_), Val(num_gpus))
end

#####Obs::: wrong here...
#####Obs::: wrong here...
######Obs::: wrong here...Obs::: wrong here...
######Obs::: wrong here...
function queens_mgpu_subproblems_organizer!(cutoff_depth, num_subproblems, prefixes, controls, starting_point, subproblems)

	for sub in 0:num_subproblems-1
		stride = sub*cutoff_depth
		for j in 1:cutoff_depth
			prefixes[stride+j] = subproblems[sub+starting_point][2][j] # subproblem_partial_permutation
			controls[stride+j] = subproblems[sub+starting_point][1][j] # subproblem_is_visited
		end
	end

end

function queens_mgpu_caller(size, cutoff_depth, __BLOCK_SIZE_, number_of_subproblems, starting_point, subproblems)

	#__BLOCK_SIZE_ = 1024

	print("Starting single-GPU-based N-Queens of size ", size-1, " Device: ",  )
	println(size-1)

	#subproblems = [Subproblem(size) for i in 1:1000000]
	
	number_of_solutions = 0
	partial_tree_size = 0
	#metrics.number_of_solutions = 0

	indexes_h = subpermutation_h = zeros(Int32, number_of_subproblems)
	subpermutation_h = zeros(Int64, cutoff_depth*number_of_subproblems)
	controls_h = zeros(Int64, cutoff_depth*number_of_subproblems)
	number_of_solutions_h = zeros(Int64, number_of_subproblems)
	tree_size_h = zeros(Int64, number_of_subproblems)

	queens_mgpu_subproblems_organizer!(cutoff_depth, number_of_subproblems, subpermutation_h, controls_h, starting_point, subproblems)

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

	return (number_of_solutions,partial_tree_size)
end #caller


function queens_mgpu_caller(::Val{size}, ::Val{cutoff_depth}, ::Val{__BLOCK_SIZE_}, ::Val{param_num_gpus}) where {size, cutoff_depth, __BLOCK_SIZE_, param_num_gpus}
	
	num_gpus = param_num_gpus
	println("Starting multi-GPU N-Queens of size ",size-1)
	if num_gpus > length(CUDA.devices())
		println("########################################################################");
		println("######## number of gpus set bigger thant he number of GPUS of the system\n######## Setting num gpus to ", length(CUDA.devices()))
		println("########################################################################");
		num_gpus = Int64(length(CUDA.devices()))
	end
	#subproblems = [Subproblem(size) for i in 1:1000000]

	#partial search -- generate some feasible valid and incomplete solutions
	(subproblems, number_of_subproblems, partial_tree_size) = @time queens_partial_search!(Val(size), Val(cutoff_depth))
	#end of the partial search

	tree_each_task = zeros(Int64,num_gpus+1)
	sols_each_task = zeros(Int64,num_gpus+1)

	#metrics.number_of_solutions = 0
    gpu_load = number_of_subproblems 

    device_load = zeros(Int64, num_gpus)
    device_starting_position = zeros(Int64, num_gpus)

	get_load_each_gpu(number_of_subproblems, num_gpus, device_load)
	get_starting_point_each_gpu(0, num_gpus, device_load, device_starting_position)

    println("\nTotal load: ",number_of_subproblems , "\nTotal CPU load: ", 0 ,"  - Number of GPUS: ", num_gpus," - GPU load: ", gpu_load);
    
	println("\nLoad of each GPU: ");
	for device in 1:num_gpus
		println("Device - ", device, " - Load: ", device_load[device])
	end
	for device in 1:num_gpus
		println("Starting point device - ", device, " - ", device_starting_position[device])
	end

	@sync begin
			for gpu_dev in 1:num_gpus
				@async begin
					device!(gpu_dev-1)
					println("gpu: ", gpu_dev-1)
					(sols_each_task[gpu_dev],tree_each_task[gpu_dev]) = queens_mgpu_caller(size, 
					                                                                        cutoff_depth, 
																							__BLOCK_SIZE_, 
																							device_load[gpu_dev],
					                                                                        device_starting_position[gpu_dev], 
																							subproblems)
					# do work on GPU 0 here
				end
			end##for
	end##syncbegin

	final_tree = sum(tree_each_task) + partial_tree_size
	final_num_sols = sum(sols_each_task)
	println("\n", " ", final_tree, " ", final_num_sols)
end