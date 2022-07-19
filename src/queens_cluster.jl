# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform aware function queens({node_count::(@atleast 2), 
                                 accelerator_count::(@atleast 1),    
                                 accelerator_api::CUDA},
                                 size)
    # MPI.jl code CUDA code for exploiting GPU-based cluster computing (one GPU per node)

end