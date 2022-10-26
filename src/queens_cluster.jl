# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform aware function init_queens({node_count::(@atleast 2 P), 
                                      accelerator_count::(@atleast 1),    
                                      accelerator_api::(@api CUDA)}) where P
    
    addprocs(P)

end

@platform aware function queens({node_count::(@atleast 2), 
                                 accelerator_count::(@atleast 1),    
                                 accelerator_api::(@api CUDA)},
                                 size)
    

end