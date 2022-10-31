# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------


macro serial(size)
	queens_serial(size)
end

macro mcore(size)
	queens_mcore(size)
end

macro sgpu(size)
	queens_sgpu(size)
end

macro mgpu(size)
	queens_mgpu(size)
end

macro mcoremgpu(size)
	queens_mgpu_mcore(size)
end

macro cluster(size)
	queens_distributed(size)
end

export @serial, @mcore, @sgpu, @mcoremgpu, @mgpu, @cluster





