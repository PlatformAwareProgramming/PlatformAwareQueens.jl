# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform default function queens(size)
    
end

@platform aware function queens({processor_core_count::(@atleast 2)}, size)
    
    subproblems_pool =  serial_search!(size,cutoff_depth)
    pool_size = size(subproblems_pool)
	thread_load = div(pool_size,num_threads)
	@sync begin
		for ii in 0:(num_threads-1)
			local i = ii
			Threads.@spawn begin
				for j in 1:thread_load
					s = i*thread_load + j
					results += serial_search!(size, cutoff_depth, subproblems_pool[s])
				end
			end
		end
	end

end

@platform aware function queens({accelerator_count::(@atleast 1), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::CUDA}, 
                                size)
    # CUDA code for a single device follows ...

end

@platform aware function queens({accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::CUDA}, 
                                size)
    # CUDA code for a multiple devices follows ...

end

@platform aware function queens({processor_core_count::(@atleast 2), 
                                 accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::CUDA}, 
                                size)
    # Multithread code (@spawn) and CUDA code for exploiting multiple cores 
    #     and multiple devices follows ...

end

@platform aware function queens({node_count::(@atleast 2), 
                                 accelerator_count::(@atleast 1),
                                 accelerator_api::CUDA}
                                size)
    # MPI.jl code CUDA code for exploiting GPU-based cluster computing (one GPU per node)

end