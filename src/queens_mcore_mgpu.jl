# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform aware function init_queens({processor_count::(@atleast 2), 
                                      accelerator_count::(@atleast 2), 
                                      accelerator_manufacturer::NVIDIA,
                                      accelerator_api::(@api CUDA)})
	nothing
end

@platform aware function init_queens({processor_count::(@just 1), 
									  processor_core_count::(@atleast 2),
                                      accelerator_count::(@atleast 2), 
                                      accelerator_manufacturer::NVIDIA,
                                      accelerator_api::(@api CUDA)})
	nothing
end

@platform aware function init_queens({node_provider::CloudProvider,
								      node_vcpus_count::(@atleast 2), 
                                      accelerator_count::(@atleast 2), 
                                      accelerator_manufacturer::NVIDIA,
                                      accelerator_api::(@api CUDA)})
	nothing
end

@platform aware function queens({processor_count::(@atleast 2), 
                                 accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                size)
	@time queens_mgpu_mcore(size)
end

@platform aware function queens({processor_count::(@just 1),
								 processor_core_count::(@atleast 2), 
                                 accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                size)
	@time queens_mgpu_mcore(size)
end

@platform aware function queens({node_provider::CloudProvider,
								 node_vcpus_count::(@atleast 2), 
                                 accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                size)

	@time queens_mgpu_mcore(size)

end

function get_cpu_load(percent::Float64, num_subproblems::Int64)::Int64
    return floor(Int64,num_subproblems*percent)
end

function queens_mgpu_mcore(size) 
	
	size += 1
	cutoff_depth = getCutoffDepth()

	num_gpus = Int64(length(CUDA.devices()))
	num_threads = Threads.nthreads()

	subproblems, number_of_subproblems, partial_tree_size = @time queens_partial_search!(Val(size), cutoff_depth)

	tree_each_task = zeros(Int64, num_gpus + 1)
	sols_each_task = zeros(Int64, num_gpus + 1)

	cpup = getCpuPortion()
	cpu_load = get_cpu_load(cpup, number_of_subproblems)
    gpu_load = number_of_subproblems - cpu_load

    device_load = zeros(Int64, num_gpus)
    device_starting_position = zeros(Int64, num_gpus)
	if gpu_load > 0
		get_load_each_gpu(gpu_load, num_gpus, device_load)
		get_starting_point_each_gpu(cpu_load, num_gpus, device_load, device_starting_position)
	end

    @info "Total load: $number_of_subproblems, CPU percent: $(cpup*100)%" 
	@info "CPU load: $cpu_load, Number of threads: $num_threads"
	@info "GPU load: $gpu_load, Number of GPUS: $num_gpus"
    
	if gpu_load > 0
		for device in 1:num_gpus
			@info "Device: $device, Load: $(device_load[device]), Start point: $(device_starting_position[device])"
		end
	end

	@sync begin
		if num_gpus > 0 && gpu_load > 0
			for gpu_dev in 1:num_gpus
				Threads.@spawn begin
					device!(gpu_dev-1)
					@info "- starting device: $(gpu_dev - 1)"
					(sols_each_task[gpu_dev],tree_each_task[gpu_dev]) = queens_gpu_caller(size, 
					                                                                      cutoff_depth, 																						 
																						  device_load[gpu_dev],
					                                                                      device_starting_position[gpu_dev], 
																						  subproblems)
				end
			end
		end 
		Threads.@spawn begin
			if cpu_load > 0 
				@info "- starting host on $num_threads threads"
				(sols_each_task[num_gpus+1],tree_each_task[num_gpus+1]) = queens_mcore_caller(size,				                                                                            
																							  cpu_load,
																							  subproblems) 
			end
		end 
	end
	final_tree = sum(tree_each_task) + partial_tree_size
	final_num_sols = sum(sols_each_task)

	return final_num_sols, final_tree
end