module simple_implicant;

import std.format;

import std.stdio;
import std.algorithm.mutation : reverse;
import std.algorithm;

import std.array;
import std.container;
import std.range;
import core.bitop;

enum SimpleImplicantValue
{
    TRUE,
    FALSE,
    DONT_CARE
}
@safe
string simple_implicant_to_string(SimpleImplicantValue[] simple_implicant, char[] column_names)
{
    simple_implicant = simple_implicant;
    int shift = cast(int) column_names.length - 1;
    string returnable = "";
    if(simple_implicant.length > column_names.length){
        throw new Exception("SIMPLE IMPLICANT LONGER THAN COLUMN NAMES!!!");
    }
    foreach (simple_implicant_bit; simple_implicant)
    {
        if (simple_implicant_bit != SimpleImplicantValue.DONT_CARE)
        {
            returnable ~= (simple_implicant_bit == SimpleImplicantValue.TRUE) ? format("%s", column_names[shift])
                : format("%s'", column_names[shift]);
        }

        shift--;
    }
    return returnable;
}
@safe
bool value_matches_simple_implicant(uint value, SimpleImplicantValue[] simple_implicant)
{
    int shift = 0;
    foreach (SimpleImplicantValue simple_implicant_bit; simple_implicant)
    {
        uint bit = (value >> shift) & 0b1;
        if (simple_implicant_bit == SimpleImplicantValue.TRUE && bit == 0)
        {
            return false;
        }
        if (simple_implicant_bit == SimpleImplicantValue.FALSE && bit == 1)
        {
            return false;
        }
        shift++;
    }

    return true;
}

/*
W mojej skromnej opinii ta funkcja jest trochę brzydka ale robi co musi.
*/
@safe
SimpleImplicantValue[] get_simple_implicant(uint cube, uint[] block_matrix, uint max_value,char[] column_names)
{
    uint mask = 0;
    uint best_mask = 0;
    uint best_mask_column_count = cast(uint)column_names.length;
    for(int i = 0;i < best_mask_column_count;i++){
        best_mask = best_mask << 1;
        best_mask++;
    }
    while (mask < max_value)
    {
        uint[] matrix = block_matrix.dup;
        for (int i = 0; i < matrix.length; i++)
        {
            matrix[i] = matrix[i] & mask;
        }
        for (int i = 0; i < matrix.length; i++)
        {
            matrix[i] = matrix[i] > 0;
        }
        uint sum = matrix[0];
        for (int i = 1; i < matrix.length; i++)
        {
            sum = matrix[i] & sum;
        }
        if (sum > 0)
        {
            if (popcnt(mask) < best_mask_column_count)
            {
                best_mask = mask;
                best_mask_column_count = popcnt(mask);
            }

        }
        mask++;
    }
    SimpleImplicantValue[] product = [];
    uint i = 0;
    while (best_mask > 0)
    {
        uint mask_bit_value = best_mask & 0b1;
        if (mask_bit_value == 0)
        {
            product ~= SimpleImplicantValue.DONT_CARE;
        }
        else
        {
            product ~= (cube & 0b1) == 1 ? SimpleImplicantValue.TRUE
                : SimpleImplicantValue.FALSE;
        }
        cube = cube >> 1;
        best_mask = best_mask >> 1;
        i++;
    }
    if(product.length > column_names.length){
        throw new Exception("No simple implicants found!");
    }
    return product;
}
uint[] remove_values_matching_simple_implicant(uint[] source, SimpleImplicantValue[] simple_implicant)
{
    uint[] cut = [];
    foreach (uint row; source)
    {
        if (!value_matches_simple_implicant(row, simple_implicant))
        {
            cut ~= row;
        }
    }
    return cut;
}
