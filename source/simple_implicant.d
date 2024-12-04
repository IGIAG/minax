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

struct SimpleImplicant {
    uint cube;
    uint mask;
    bool matches_value(uint v){
        return (cube & mask) == (v & mask);
    }
}

@safe
string simple_implicant_to_string(SimpleImplicant _simple_implicant, char[] column_names)
{
    string returnable = "";
    char[] r_column_names = column_names.dup.reverse();
    uint shiftR = 0;
    while(shiftR < r_column_names.length){
        if((_simple_implicant.mask >> shiftR) % 2 == 0){
            shiftR++;
            continue;
        }
        if((_simple_implicant.cube >> shiftR) % 2 == 0){
            returnable ~= r_column_names[shiftR] ~ "'";
        }
        else {
            returnable ~= r_column_names[shiftR];
        }
        
        
        shiftR++;
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
SimpleImplicant[] get_simple_implicant(uint cube, uint[] block_matrix, uint max_value,char[] column_names)
{
    uint mask = 0;
    uint best_mask = 0;
    uint best_mask_column_count = cast(uint)column_names.length;
    max_value = 1;
    for(int i = 0;i < column_names.length;i++){
        max_value = max_value << 1;
        max_value += 1;
    }

    SimpleImplicant[][] simple_implicant_ranks = new SimpleImplicant[][0b1 <<column_names.length];

    for(int i = 0;i < best_mask_column_count;i++){
        best_mask = best_mask << 1;
        best_mask++;
    }
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
        uint sum = matrix[0];
        for (int i = 1; i < matrix.length; i++)
        {
            sum = matrix[i] & sum;
        }
        if (sum > 0)
        {
            
            simple_implicant_ranks[popcnt(mask)] ~= SimpleImplicant(cube,mask);
            
        }
        mask++;
    }
    SimpleImplicant[] returnable = [];
    foreach (SimpleImplicant[] rank; simple_implicant_ranks)
    {
        if(rank.length != 0){
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
