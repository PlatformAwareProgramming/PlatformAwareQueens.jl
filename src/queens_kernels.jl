@platform parameter clear
@platform parameter processor_count
@platform parameter processor_core_count
@platform parameter accelerator_count
@platform parameter accelerator_manufacturer
@platform parameter accelerator_api
@platform parameter node_provider
@platform parameter node_vcpus_count
@platform parameter node_count

@platform default function init_queens()
	nothing
end

# FALLBACK (serial)

@platform default function queens(size)
    
	@info "serial kernel"
	@time queens_serial(size)
 
 end

# SINGLE GPU (sgpu)

@platform aware function init_queens({node_count::@just(1),
	                                  accelerator_count::(@just 1), 
                                 	  accelerator_manufacturer::NVIDIA,
                                 	  accelerator_api::(@api CUDA)})
	configureHeap()
end

@platform aware function queens({node_count::@just(1),
	                             accelerator_count::(@just 1), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                 size)
	
	@info "sgpu kernel"
	@time queens_sgpu(size)
end

# MULTIPLE GPU (mgpu)

@platform aware function init_queens({node_count::@just(1),
	                                  accelerator_count::(@atleast 2), 
                                      accelerator_manufacturer::NVIDIA,
                                      accelerator_api::(@api CUDA)})
	configureHeap()
end


@platform aware function queens({node_count::@just(1), 
	                             accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                size)
	@info "mgpu kernel"
	@time queens_mgpu(size)
end

# MULTI-CORE (mcore)

@platform aware function init_queens({node_provider::OnPremises,
									  node_count::@just(1),
	                                  processor_count::(@atleast 2),
									  accelerator_count::@just(0)})
   nothing
end

@platform aware function init_queens({node_provider::OnPremises,
									  node_count::@just(1),
									  processor_count::(@just 1),
	                                  processor_core_count::(@atleast 2),
									  accelerator_count::@just(0)})
   nothing
end

@platform aware function init_queens({node_provider::CloudProvider,
									  node_count::@just(1),
								      node_vcpus_count::(@atleast 2),
									  accelerator_count::@just(0)})
    nothing
end

@platform aware function queens({node_provider::OnPremises,
							     node_count::@just(1),
	                             processor_count::(@atleast 2),
								 accelerator_count::@just(0)}, size)
	@info "mcore kernel"
    @time queens_mcore(size)
end

@platform aware function queens({node_provider::OnPremises,
								 processor_count::(@just 1),
	                             processor_core_count::(@atleast 2),
								 accelerator_count::@just(0)}, size)
	@info "mcore kernel"
    @time queens_mcore(size)
end

@platform aware function queens({node_provider::CloudProvider,
								 node_vcpus_count::(@atleast 2),
								 accelerator_count::@just(0)}, size)
 	@info "mcore kernel"
   @time queens_mcore(size)
end

# MULTI-CORE/MULTI-GPU (mcore-mgpu)


@platform aware function init_queens({node_count::@just(1),
									  processor_count::(@atleast 2), 
                                      accelerator_count::(@atleast 2), 
                                      accelerator_manufacturer::NVIDIA,
                                      accelerator_api::(@api CUDA)})
	configureHeap()
end

@platform aware function init_queens({node_count::@just(1),
									  processor_count::(@just 1), 
									  processor_core_count::(@atleast 2),
                                      accelerator_count::(@atleast 2), 
                                      accelerator_manufacturer::NVIDIA,
                                      accelerator_api::(@api CUDA)})
	configureHeap()
end

@platform aware function init_queens({node_count::@just(1),
									  node_provider::CloudProvider,
								      node_vcpus_count::(@atleast 2), 
                                      accelerator_count::(@atleast 2), 
                                      accelerator_manufacturer::NVIDIA,
                                      accelerator_api::(@api CUDA)})
	configureHeap()
end

@platform aware function queens({node_count::@just(1),
	                             processor_count::(@atleast 2), 
                                 accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                size)
	@info "mcore/mgpu kernel"
	@time queens_mgpu_mcore(size)
end

@platform aware function queens({node_count::@just(1),
	   						     processor_count::(@just 1),
								 processor_core_count::(@atleast 2), 
                                 accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                size)
	@info "mcore/mgpu kernel"
	@time queens_mgpu_mcore(size)
end

@platform aware function queens({node_count::@just(1),
								 node_provider::CloudProvider,
								 node_vcpus_count::(@atleast 2), 
                                 accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::(@api CUDA)}, 
                                size)

	@info "mcore/mgpu kernel"
	@time queens_mgpu_mcore(size)

end

# DISTRIBUTED (cluster)

@platform aware function init_queens({node_count::(@atleast 2 P)}) where P
    @info "running on $P nodes"
end

@platform aware function queens({node_count::(@atleast 2)}, size)
    @info "distributed kernel"
    @time queens_distributed(size)
end



init_queens()
