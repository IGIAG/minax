module simple_implicant;

import std.format;

import std.stdio;
import std.algorithm.mutation : reverse;
import std.algorithm;

import std.array;
import std.container;
import std.range;

enum SimpleImplicantValue
{
    TRUE,
    FALSE,
    DONT_CARE
}

string simple_implicant_to_string(SimpleImplicantValue[] simple_implicant, char[] column_names)
{
    simple_implicant = simple_implicant;
    int shift = cast(int) column_names.length - 1;
    string returnable = "";
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

SimpleImplicantValue[] get_simple_implicant(uint cube, uint[] block_matrix, uint max_value)
{
    uint mask = 0;
    while (mask < max_value)
    {
        uint[] matrix = block_matrix.dup;
        for (int i = 0; i < matrix.length; i++)
        {
            matrix[i] = matrix[i] & mask;
        }
        for (int i = 0; i < matrix.length; i++)
        {
            matrix[i] = (matrix[i] > 0) ? 1 : 0;
        }
        uint sum = matrix[0];
        for (int i = 1; i < matrix.length; i++)
        {
            sum = matrix[i] & sum;
        }
        if (sum > 0)
        {
            SimpleImplicantValue[] product = [];
            uint cube_mod = cube;
            uint i = 0;
            while (mask > 0)
            {
                uint mask_bit_value = mask & 0b1;
                if (mask_bit_value == 0)
                {
                    product ~= SimpleImplicantValue.DONT_CARE;
                }
                else
                {
                    product ~= (cube_mod & 0b1) == 1 ? SimpleImplicantValue.TRUE
                        : SimpleImplicantValue.FALSE;
                }
                cube_mod = cube_mod >> 1;
                mask = mask >> 1;
                i++;
            }
            return product;
        }
        mask++;
    }
    return [];
}

uint[] remove_values_matching_simple_implicant(uint[] source, SimpleImplicantValue[] simple_implicant)
{
    auto F_cut = Array!uint(source);
    foreach (uint row; source)
    {
        if (value_matches_simple_implicant(row, simple_implicant))
        {
            auto range = F_cut[];
            auto found = range.find(row);
            F_cut.linearRemove(found.take(1));
        }
    }
    return F_cut.data;
}
