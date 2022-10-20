# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------


macro serial(size)
	@time queens_serial(Val(size+1))
end

macro mcore(size, cutoff_depth, num_threads)
	@time queens_mcore_caller(Val(size+1), Val(cutoff_depth+1), Val(num_threads))
end

macro sgpu(size, cutoff_depth, __BLOCK_SIZE_)
	@time queens_sgpu_caller(Val(size+1), Val(cutoff_depth+1), Val(__BLOCK_SIZE_))
end

macro mgpu(size, cutoff_depth, __BLOCK_SIZE_, num_gpus)
	@time queens_mgpu_caller(Val(size+1), Val(cutoff_depth+1), Val(__BLOCK_SIZE_), Val(num_gpus))
end

macro mcoremgpu(size, cutoff_depth, __BLOCK_SIZE_, num_gpus, cpup, num_threads)
	@time queens_mgpu_mcore_caller(Val(size+1), Val(cutoff_depth+1), Val(__BLOCK_SIZE_), Val(num_gpus), Val(cpup), Val(num_threads))
end

export @serial, @mcore, @sgpu, @mcoremgpu, @mgpu





