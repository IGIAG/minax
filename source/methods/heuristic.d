module methods.heuristic;

import simple_implicant;

import block_matrix;

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
			SimpleImplicant cubes_simple_implicant = get_simple_implicant(cube, block_matrix, cast(
					int)(column_names.length * column_names.length), column_names)[0];
			simple_implicants ~= cubes_simple_implicant;
			F = simple_implicant.remove_values_matching_simple_implicant(F, cubes_simple_implicant);
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

unittest
{
    import std.random;
	import std.stdio;
	import std.format;
	import std.datetime.stopwatch;
	import test_constants;
	import misc;
	StopWatch sw = StopWatch(AutoStart.no);
	

    float sum_of_final_implicants = 0;
    const float number_of_functions_to_test = NUM_FUNTIONS_TO_TEST;
    const uint columns = COLUMNS;
    
    
    for (int j = 0; j < number_of_functions_to_test; j++)
    {
		TruthTable truth_table = get_random_truth_table(j,columns);
		sw.start();
        SimpleImplicant[] simple_implicants = heuristic_method(truth_table.on_set, truth_table.off_set, truth_table.column_names);
		sw.stop();
        foreach (SimpleImplicant implicant; simple_implicants)
        {
            truth_table.on_set = remove_values_matching_simple_implicant(truth_table.on_set, implicant);
        }
        sum_of_final_implicants += simple_implicants.length;
        assert(truth_table.on_set.length == 0);
    }

}
