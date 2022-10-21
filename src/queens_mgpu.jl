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

function get_load_each_gpu(gpu_load, num_gpus, device_load)

	for device in 1:num_gpus
		device_load[device] = floor(Int64, gpu_load/num_gpus)
		if(device == num_gpus)
			device_load[device]+= gpu_load%num_gpus
		end
	end

end ###

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
					(sols_each_task[gpu_dev],tree_each_task[gpu_dev]) = queens_gpu_caller(size, 
					                                                                      cutoff_depth, 
																						  _BLOCK_SIZE_, 
																						  device_load[gpu_dev],
					                                                                      device_starting_position[gpu_dev], 
																						  subproblems)
				end
			end##for
	end##syncbegin

	final_tree = sum(tree_each_task) + partial_tree_size
	final_num_sols = sum(sols_each_task)
	println("\n", " ", final_tree, " ", final_num_sols)
end