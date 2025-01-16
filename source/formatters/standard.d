module formatters.standard;

import binary_matrix_utils.simple_implicant;

import std.array;

string simple_implicant_to_string(SimpleImplicant[] simple_implicants, char[] column_names)
{
    string[] stringed_simple_implicants = [];
    foreach (SimpleImplicant simple_implicant; simple_implicants)
    {
        stringed_simple_implicants ~= simple_implicant.to_string(column_names);
    }
    return stringed_simple_implicants.join(" + ");
}
