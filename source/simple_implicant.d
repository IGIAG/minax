module simple_implicant;

import std.format;

import std.stdio;
import std.algorithm.mutation : reverse;
import std.algorithm;

import std.array;
import std.container;
import std.range;
import core.bitop;

import std.functional;

import std.string;
import std.format;

enum SimpleImplicantValue
{
    TRUE,
    FALSE,
    DONT_CARE
}

struct SimpleImplicant
{
    uint cube;
    uint mask;
    bool matches_value(uint v)
    {
        return (cube & mask) == (v & mask);
    }

    string to_string(char[] column_names)
    {
        string returnable = "";
        char[] r_column_names = column_names.dup.reverse();
        uint shiftR = 0;
        while (shiftR < r_column_names.length)
        {
            if ((mask >> shiftR) % 2 == 0)
            {
                shiftR++;
                continue;
            }
            if ((cube >> shiftR) % 2 == 0)
            {
                returnable ~= r_column_names[shiftR] ~ "'";
            }
            else
            {
                returnable ~= r_column_names[shiftR];
            }

            shiftR++;
        }

        return returnable;
    }
}

string simple_implicant_to_string(SimpleImplicant[] simple_implicants, char[] column_names)
{
    string[] stringed_simple_implicants = [];
    foreach (SimpleImplicant simple_implicant; simple_implicants)
    {
        stringed_simple_implicants ~= simple_implicant.to_string(column_names);
    }
    return stringed_simple_implicants.join(" + ");
}

/*
W mojej skromnej opinii ta funkcja jest trochę brzydka ale robi co musi.
*/

alias fast_simple_implicants = memoize!(get_simple_implicant,1000_000);

SimpleImplicant[] get_simple_implicant(uint cube, uint[] block_matrix, uint max_value, char[] column_names)
{
    uint mask = 0;
    uint best_mask = 0;
    max_value = (1 << column_names.length) - 1;

    SimpleImplicant[][] simple_implicant_ranks = new SimpleImplicant[][0b1 << column_names.length];

    best_mask = max_value;
    while (mask <= max_value)
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
        uint sum = matrix.length > 0 ? matrix[0] : 0;
        for (int i = 1; i < matrix.length; i++)
        {
            sum = matrix[i] & sum;
        }
        if (sum > 0)
        {

            simple_implicant_ranks[popcnt(mask)] ~= SimpleImplicant(cube, mask);

        }
        mask++;
    }
    SimpleImplicant[] returnable = [];
    foreach (SimpleImplicant[] rank; simple_implicant_ranks)
    {
        if (rank.length != 0)
        {
            //rank = rank.reverse;
            foreach (SimpleImplicant implicant; rank)
            {
                returnable ~= implicant;
            }
            break;
        }

    }
    assert(returnable.length > 0);
    return returnable;
}

alias fast_remove_matching = memoize!(remove_values_matching_simple_implicant,1000_000);

uint[] remove_values_matching_simple_implicant(uint[] source, SimpleImplicant simple_implicant)
{
    uint[] cut = [];
    foreach (uint row; source)
    {
        if (!simple_implicant.matches_value(row))
        {
            cut ~= row;
        }
    }
    return cut;
}
