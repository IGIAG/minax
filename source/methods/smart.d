module methods.smart;

import simple_implicant;

import block_matrix;
import std.functional;

alias fast_smart_method = memoize!smart_method;

SimpleImplicant[] smart_method(uint[] F, uint[] R, char[] column_names)
{
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
    return fast_smart_method(remove_values_matching_simple_implicant(F.dup, best), R, column_names) ~ best;
}