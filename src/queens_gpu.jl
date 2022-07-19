# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform aware function queens({accelerator_count::(@atleast 1), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::CUDA}, 
                                 size)
    # CUDA code for a single device follows ...

end
