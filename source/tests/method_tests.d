module tests.method_tests;

unittest
{
    import std.random;
    import std.stdio;
    import std.format;
    import std.datetime.stopwatch;
    import tests.test_constants;
    import misc;
    import methods.heuristic;
    import methods.smart;
    import methods.none;
    import methods.systemic;
    import simple_implicant;
    import methods.systematic;

    void test_method(SimpleImplicant[] function(uint[], uint[], char[]) tested, string method_name)
    {
        float sum_of_final_implicants = 0;
        const float number_of_functions_to_test = NUM_FUNTIONS_TO_TEST;
        const uint columns = COLUMNS;
        StopWatch sw = StopWatch(AutoStart.no);
        for (int j = 0; j < number_of_functions_to_test; j++)
        {
            TruthTable truth_table = get_random_truth_table(j, columns);
            sw.start();
            SimpleImplicant[] simple_implicants = tested(truth_table.on_set, truth_table.off_set, truth_table
                    .column_names);
            sw.stop();
            foreach (SimpleImplicant implicant; simple_implicants)
            {
                truth_table.on_set = remove_values_matching_simple_implicant(truth_table.on_set, implicant);
            }
            sum_of_final_implicants += simple_implicants.length;
            assert(truth_table.on_set.length == 0);
        }
        float avg_time_per_function = sw.peek()
                .total!"usecs" / NUM_FUNTIONS_TO_TEST;
        float throughput = 1000_000 / avg_time_per_function;


        writefln("%s | Throughput: %s functions/s | Tested %s ( %s parameter ) functions and averaged %s implicants.",method_name, throughput, number_of_functions_to_test,COLUMNS,(
                    sum_of_final_implicants / NUM_FUNTIONS_TO_TEST));
    }

    test_method(&heuristic_method, "HEURISTIC");
    test_method(&smart_method, "SMART");
    test_method(&minterms, "NONE");
    //test_method(&systemic, "SYSTEMATIC");
    test_method(&systematic, "HOLY SHITT");
}
