@platform parameter clear
@platform parameter processor_count
@platform parameter processor_core_count
@platform parameter accelerator_count
@platform parameter accelerator_manufacturer
@platform parameter accelerator_api
@platform parameter node_provider
@platform parameter node_vcpus_count
@platform parameter node_count

@platform default init_queens() = nothing

# FALLBACK (serial)

@platform default function queens(size)
    
	@info "serial kernel"
	queens_serial(size)
 
 end

# SINGLE GPU (sgpu)

 @platform assumption sgpu_assumptions = {node_count::@just(1),
 									      accelerator_count::(@just 1), 
									      accelerator_manufacturer::NVIDIA,
									      accelerator_api::(@api CUDA)}

@platform aware function init_queens($sgpu_assumptions)
	configureHeap()
end

@platform aware function queens($sgpu_assumptions, size)
	@info "sgpu kernel"
	queens_sgpu(size)
end

# MULTIPLE GPU (mgpu)

@platform assumption mgpu_assumptions = {node_count::@just(1),
	                                     accelerator_count::(@atleast 2), 
                                         accelerator_manufacturer::NVIDIA,
                                         accelerator_api::(@api CUDA)}

@platform aware function init_queens($mgpu_assumptions)
	configureHeap()
end

@platform aware function queens($mgpu_assumptions, size)
	@info "mgpu kernel"
	queens_mgpu(size)
end

# MULTI-CORE (mcore)

@platform assumption mcore_assumptions_1 = {node_provider::OnPremises,
									        node_count::@just(1),
	                                        processor_count::(@atleast 2),
									        accelerator_count::@just(0)}

@platform assumption mcore_assumptions_2 = {node_provider::OnPremises,
									 		node_count::@just(1),
											processor_count::(@just 1),
	                                 		processor_core_count::(@atleast 2),
									 		accelerator_count::@just(0)}

@platform assumption mcore_assumptions_3 = {node_provider::CloudProvider,
									  		node_count::@just(1),
								      		node_vcpus_count::(@atleast 2),
									  		accelerator_count::@just(0)}
											
@platform aware init_queens($mcore_assumptions_1) = nothing 
@platform aware init_queens($mcore_assumptions_2) = nothing 
@platform aware init_queens($mcore_assumptions_3) = nothing

@platform aware function queens($mcore_assumptions_1, size)
	@info "mcore kernel"
    queens_mcore(size)
end

@platform aware function queens($mcore_assumptions_2, size)
	@info "mcore kernel"
    queens_mcore(size)
end

@platform aware function queens($mcore_assumptions_3, size)
 	@info "mcore kernel"
    queens_mcore(size)
end

# MULTI-CORE/MULTI-GPU (mcore-mgpu)

@platform assumption mcoremgpu_assumptions_1 = {node_count::@just(1),
									 			processor_count::(@atleast 2), 
                                      			accelerator_count::(@atleast 2), 
                                      			accelerator_manufacturer::NVIDIA,
                                      			accelerator_api::(@api CUDA)}

@platform assumption mcoremgpu_assumptions_2 = {node_count::@just(1),
									  			processor_count::(@just 1), 
									  			processor_core_count::(@atleast 2),
                                      			accelerator_count::(@atleast 2), 
                                      			accelerator_manufacturer::NVIDIA,
                                      			accelerator_api::(@api CUDA)}

@platform assumption mcoremgpu_assumptions_3 = {node_count::@just(1),
									  			node_provider::CloudProvider,
								      			node_vcpus_count::(@atleast 2), 
                                      			accelerator_count::(@atleast 2), 
                                      			accelerator_manufacturer::NVIDIA,
                                      			accelerator_api::(@api CUDA)}

@platform aware function init_queens($mcoremgpu_assumptions_1)
	configureHeap()
end

@platform aware function init_queens($mcoremgpu_assumptions_2)
	configureHeap()
end

@platform aware function init_queens($mcoremgpu_assumptions_3)
	configureHeap()
end

@platform aware function queens($mcoremgpu_assumptions_1, size)
	@info "mcore/mgpu kernel"
	queens_mgpu_mcore(size)
end

@platform aware function queens($mcoremgpu_assumptions_2, size)
	@info "mcore/mgpu kernel"
	queens_mgpu_mcore(size)
end

@platform aware function queens($mcoremgpu_assumptions_3, size)
	@info "mcore/mgpu kernel"
	queens_mgpu_mcore(size)
end

# DISTRIBUTED (cluster)

@platform aware function init_queens({node_count::(@atleast 2 P)}) where P
    @info "running on $P nodes"
end

@platform aware function queens({node_count::(@atleast 2)}, size)
    @info "distributed kernel"
    queens_distributed(size)
end

init_queens()
