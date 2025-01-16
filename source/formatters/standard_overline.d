module formatters.standard_overline;

import binary_matrix_utils.simple_implicant;

import std.range;

import formatters.standard;

string simple_implicant_to_string(SimpleImplicant[] simple_implicants, char[] column_names)
{
    return formatters.standard.simple_implicant_to_string(simple_implicants,column_names).replace("'","\u0305");
}
