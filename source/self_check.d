module self_check;

import simple_implicant;

import misc;

void verify_expression(uint[] F, uint[] R,char[] column_names,SimpleImplicant[] r1)
{
    TruthTable truth_table = TruthTable(F.dup, R.dup, column_names.dup);
    ulong offsets_length = truth_table.off_set.length;
    foreach (SimpleImplicant implicant; r1)
    {
        truth_table.on_set = remove_values_matching_simple_implicant(truth_table.on_set, implicant);
        truth_table.off_set = remove_values_matching_simple_implicant(truth_table.off_set, implicant);
        assert(truth_table.off_set.length == offsets_length);
    }
    assert(truth_table.on_set.length == 0);
}
