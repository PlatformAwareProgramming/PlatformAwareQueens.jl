# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENCE in the project root.
# ------------------------------------------------------------------

mutable struct Subproblem

	subproblem_is_visited::Array{Int64}
 	subproblem_partial_permutation::Array{Int64}

end


mutable struct Metrics

  	number_of_solutions::Int64
	partial_tree_size::Int64

end

#verifies whether a given solution/incomplete solution is feasible
function queens_is_valid_configuration(board::Union{Number, AbstractArray{<:Number}}, roll)::Bool

	for i=2:roll-1
		if (board[i] == board[roll])
			return false
		end
	end

	ld = board[roll]
	rd = board[roll]

	for j=(roll-1):-1:2
		ld -= 1
		rd += 1
		if (board[j] == ld || board[j] == rd)
			return false
		end
	end

	return true
end ##queens_is_valid_conf