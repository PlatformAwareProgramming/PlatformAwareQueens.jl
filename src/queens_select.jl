# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

function selectQueens()

	if ()

end


queens = selectQueens()




macro serial(size)
	@time queens_serial(size)
end

macro mcore(size)
	@time queens_mcore(size)
end

macro sgpu(size)
	@time queens_sgpu(size)
end

macro mgpu(size)
	@time queens_mgpu(size)
end

macro mcoremgpu(size)
	@time queens_mgpu_mcore(size)
end

export @serial, @mcore, @sgpu, @mcoremgpu, @mgpu





