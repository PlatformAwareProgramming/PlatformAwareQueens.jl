# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform aware function queens({processor_core_count::(@atleast 2), 
                                 accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                size)
    # Multithread code (@spawn) and CUDA code for exploiting multiple cores and multiple devices follows ...

	cutoff_depth = 5
	__BLOCK_SIZE_ = 128
	num_gpus = length(CUDA.devices())
    num_threads = Threads.nthreads()
	cpup = 0.2

	@time queens_mgpu_mcore_caller(Val(size+1), Val(cutoff_depth+1), Val(__BLOCK_SIZE_), Val(num_gpus), Val(cpup), Val(num_threads))

end

function get_cpu_load(percent::Float64, num_subproblems::Int64)::Int64
    return floor(Int64,num_subproblems*percent)
end

function get_starting_point_each_gpu(cpu_load::Int64, num_devices, device_load,device_starting_point)
	
	starting_point = cpu_load
	device_starting_point[1] = starting_point + 1
	if(num_devices>1)
		for device in 2:num_devices
			
			device_starting_point[device] = device_starting_point[device-1]+device_load[device-1]
		end
	end
end ###

function queens_mgpu_mcore_caller(::Val{size}, ::Val{cutoff_depth}, ::Val{__BLOCK_SIZE_}, ::Val{param_num_gpus}, ::Val{cpup}, ::Val{num_threads}) where {size, cutoff_depth, __BLOCK_SIZE_, param_num_gpus,cpup, num_threads}
	
	num_gpus = param_num_gpus
	println("Starting multi-GPU-mcore N-Queens of size ",size-1)
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
	cpu_load = get_cpu_load(cpup, number_of_subproblems)
    gpu_load = number_of_subproblems - cpu_load

    device_load = zeros(Int64, num_gpus)
    device_starting_position = zeros(Int64, num_gpus)
	if gpu_load > 0
		get_load_each_gpu(gpu_load, num_gpus, device_load)
		get_starting_point_each_gpu(cpu_load, num_gpus, device_load, device_starting_position)
	end

    println("\nTotal load: ",number_of_subproblems , "\nTotal CPU load: ", cpu_load ,"  - CPU percent: ", cpup , " - Number of GPUS: ", num_gpus," - GPU load: ", gpu_load);
    
	if gpu_load > 0
		println("\nLoad of each GPU: ");
		for device in 1:num_gpus
    		println("Device - ", device, " - Load: ", device_load[device])
   		end
		for device in 1:num_gpus
    		println("Starting point device - ", device, " - ", device_starting_position[device])
    	end
	end

	@sync begin
		if num_gpus>0 && gpu_load>0
			for gpu_dev in 1:num_gpus
				@async begin
					device!(gpu_dev-1)
					println("gpu: ", gpu_dev-1)
					(sols_each_task[gpu_dev],tree_each_task[gpu_dev]) = queens_gpu_caller(size, 
					                                                                      cutoff_depth, 
																						  __BLOCK_SIZE_, 
																						  device_load[gpu_dev],
					                                                                      device_starting_position[gpu_dev], 
																						  subproblems)
				end
			end##for
		end #if num_gpus
		@async begin
			if cpu_load>0 
				#problem size, cutoff, num threads for the mcore part, number of subproblems and the pool
				(sols_each_task[num_gpus+1],tree_each_task[num_gpus+1]) = queens_mcore_caller(size,
				                                                                              cutoff_depth,
																							  num_threads,
																							  cpu_load,
																							  subproblems) 
			end
		end ##if
	end##syncbegin
	final_tree = sum(tree_each_task) + partial_tree_size
	final_num_sols = sum(sols_each_task)
	println("\n", " ", final_tree, " ", final_num_sols)
end