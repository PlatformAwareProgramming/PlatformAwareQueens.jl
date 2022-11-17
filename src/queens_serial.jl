# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

@platform default function init_queens()
	@info "serial kernel"
end

@platform default queens(size) = queens_serial(size)

function queens_serial(size)

	size += 1

	local_visited, local_permutation = createArrays(Val(size))

	queens_tree_explorer_serial(Val(size), Val(1), local_visited, local_permutation)

end #queens serial