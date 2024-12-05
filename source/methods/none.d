module methods.none;

import simple_implicant;

import std.stdio;

SimpleImplicant[] minterms(uint[] F,uint[] R,char[] column_names){
    SimpleImplicant[] returnable = [];
    uint mask = 0b0;
    for(int i = 0;i < cast(long)column_names.length - 1;i++){
        mask = mask << 1;
        mask++;
    }
    foreach (uint row; F)
    {
        returnable ~= SimpleImplicant(row,mask);
    }
    return returnable;
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
        SimpleImplicant[] simple_implicants = minterms(truth_table.on_set, truth_table.off_set, truth_table.column_names);
		sw.stop();
        foreach (SimpleImplicant implicant; simple_implicants)
        {
            truth_table.on_set = remove_values_matching_simple_implicant(truth_table.on_set, implicant);
        }
        sum_of_final_implicants += simple_implicants.length;
        assert(truth_table.on_set.length == 0);
    }

}
