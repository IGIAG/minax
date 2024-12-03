module smart;

import simple_implicant;

import block_matrix;

import core.bitop : popcnt;

import std.stdio;

import std.random;

SimpleImplicant[] smart_method(uint[] F, uint[] R, char[] column_names)
{
    if (F.length == 0)
    {
        return [];
    }
    writeln("step");
    foreach (uint row; F)
    {
        writefln("Remaining: %b", row);
    }
    writeln("--");
    SimpleImplicant[] returnable = [];
    uint[] zero_matrix = generate_block_matrix(F[0], R);
    SimpleImplicant best = get_simple_implicant(F[0], zero_matrix, cast(int)(
            column_names.length * column_names.length), column_names)[0];
    uint best_coverage = uint.max;
    foreach (uint k; F)
    {

        uint[] block_matrix = generate_block_matrix(k, R);
        SimpleImplicant[] new_implicants = get_simple_implicant(k, block_matrix, cast(int)(
                column_names.length * column_names.length), column_names);
        if(new_implicants.length == 0){
            continue;
        }
        SimpleImplicant implicant = new_implicants[0];
        uint coverage = cast(uint) remove_values_matching_simple_implicant(F.dup, implicant).length;
        if (coverage < best_coverage)
        {
            best = implicant;
            best_coverage = coverage;

        }
    }
        returnable ~= best;

        return returnable ~ smart_method(remove_values_matching_simple_implicant(F.dup, best), R, column_names);

}
    
