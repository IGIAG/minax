module tests.method_tests;

unittest
{
    import std.random;
    import std.stdio;
    import std.format;
    import std.datetime.stopwatch;
    import test_constants;
    import misc;
    import methods.heuristic;
    import methods.smart;
    import methods.none;
    import simple_implicant;

    void test_method(SimpleImplicant[] function(uint[], uint[], char[]), string method_name)
    {
        float sum_of_final_implicants = 0;
        const float number_of_functions_to_test = NUM_FUNTIONS_TO_TEST;
        const uint columns = COLUMNS;
        StopWatch sw = StopWatch(AutoStart.no);
        for (int j = 0; j < number_of_functions_to_test; j++)
        {
            TruthTable truth_table = get_random_truth_table(j, columns);
            sw.start();
            SimpleImplicant[] simple_implicants = heuristic_method(truth_table.on_set, truth_table.off_set, truth_table
                    .column_names);
            sw.stop();
            foreach (SimpleImplicant implicant; simple_implicants)
            {
                truth_table.on_set = remove_values_matching_simple_implicant(truth_table.on_set, implicant);
            }
            sum_of_final_implicants += simple_implicants.length;
            assert(truth_table.on_set.length == 0);
        }

        writefln("%s took %s ms to process %s functions and averaged %s implicants.",method_name, sw.peek()
                .total!"msecs" / NUM_FUNTIONS_TO_TEST, number_of_functions_to_test,(
                    sum_of_final_implicants / NUM_FUNTIONS_TO_TEST));
    }

    test_method(&heuristic_method, "HEURISTIC");
    test_method(&smart_method, "SMART");
    test_method(&minterms, "NONE");
}
