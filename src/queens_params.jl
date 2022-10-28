# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform parameter clear
@platform parameter processor_count
@platform parameter processor_core_count
@platform parameter accelerator_count
@platform parameter accelerator_manufacturer
@platform parameter accelerator_api
@platform parameter node_provider
@platform parameter node_vcpus_count
@platform parameter node_count


global const cutoff_depth = Ref{Integer}(3)

function setCutoffDepth(v)
   cutoff_depth[] = v 
end

function getCutoffDepth()
    cutoff_depth[] + 1
end
 
global const cpu_percentage = Ref{Real}(0.2)

function setCpuPortion(v)
    cpu_percentage[] = v 
 end
 
function getCpuPortion()
    cpu_percentage[]
end
 
global const __BLOCK_SIZE_ = Ref{Integer}(128)

function setBlockSize(v)
    __BLOCK_SIZE_[] = v 
 end
 
function getBlockSize()
    __BLOCK_SIZE_[]
end

export setCutoffDepth, getCutoffDepth,
       setBlockSize, getBlockSize,
       setCpuPortion, getCpuPortion