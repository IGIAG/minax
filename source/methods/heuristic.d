module methods.heuristic;

import binary_matrix_utils.simple_implicant;
import binary_matrix_utils.block_matrix;

import std.random : randomShuffle;

SimpleImplicant[] heuristic_method(uint[] F,uint[] R,char[] column_names){
    SimpleImplicant[] simple_implicants = [];
	uint iteration = 0;
	while (F.length > 0 && iteration < uint.max)
	{
		uint cube = F[0];
		uint[] block_matrix = generate_block_matrix(cube, R);
		try
		{
			SimpleImplicant cubes_simple_implicant = get_simple_implicant(cube, block_matrix,column_names)[0];
			simple_implicants ~= cubes_simple_implicant;
			F = binary_matrix_utils.simple_implicant.remove_values_matching_simple_implicant(F, cubes_simple_implicant);
		}
		catch (Exception e)
		{
			F = F.randomShuffle(); //if couldn't find simple implicant for cube, shuffle array to get better cube at the begining
		}
		iteration++;
	}
	if (iteration == uint.max)
	{
		throw new Exception("ITERATION LIMIT REACHED!!!");
	}
    return simple_implicants;
}