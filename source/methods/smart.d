module methods.smart;

import simple_implicant;

import block_matrix;

import core.bitop : popcnt;

import std.stdio;
import std.string;

import std.random;

struct Record
{
    SimpleImplicant implicant;
    uint covered;
}

SimpleImplicant[] smart_method(uint[] F, uint[] R, char[] column_names)
{
    SimpleImplicant[uint] coverage_map;
    SimpleImplicant best;
    uint best_coverage = 0;
    foreach (uint cube; F)
    {
        SimpleImplicant[] implicants = get_simple_implicant(cube, generate_block_matrix(cube, R), 2 << column_names
                .length, column_names);
        foreach (SimpleImplicant implicant; implicants)
        {
            uint coverage = cast(uint)(F.length - remove_values_matching_simple_implicant(F.dup, implicant)
                    .length);
            if (coverage > best_coverage)
            {
                best = implicant;
                best_coverage = coverage;
            }
        }
    }
    if (F.length == 0)
    {
        return [];
    }
    return smart_method(remove_values_matching_simple_implicant(F.dup, best), R, column_names) ~ best;

}

unittest
{
    import std.random : randomShuffle;
    import std.datetime.stopwatch;
    import test_constants;
    import misc;

    float sum_of_final_implicants = 0;
    const float number_of_functions_to_test = NUM_FUNTIONS_TO_TEST;
    const uint columns = COLUMNS;
    StopWatch sw = StopWatch(AutoStart.no);
    
    for (int j = 0; j < number_of_functions_to_test; j++)
    {
        TruthTable truth_table = get_random_truth_table(j,columns);
        sw.start();
        SimpleImplicant[] simple_implicants = smart_method(truth_table.on_set, truth_table.off_set, truth_table.column_names);
        sw.stop();
        foreach (SimpleImplicant implicant; simple_implicants)
        {
            truth_table.on_set = remove_values_matching_simple_implicant(truth_table.on_set, implicant);
        }
        sum_of_final_implicants += simple_implicants.length;
        assert(truth_table.on_set.length == 0);
    }
}
