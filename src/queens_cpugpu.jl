# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform aware function queens({processor_core_count::(@atleast 2), 
                                 accelerator_count::(@atleast 2), 
                                 accelerator_manufacturer::NVIDIA,
                                 accelerator_api::CUDA}, 
                                size)
    # Multithread code (@spawn) and CUDA code for exploiting multiple cores and multiple devices follows ...

end