# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

function queens_serial(size)

	size += 1

	local_visited, local_permutation = createArrays(Val(size))

	queens_tree_explorer_serial(Val(size), Val(1), local_visited, local_permutation)

end #queens serial