module methods.greedy;
import binary_matrix_utils.simple_implicant;
import methods.smart;
import binary_matrix_utils.block_matrix;
import std.stdio;
import core.bitop;
import binary_matrix_utils.misc;
import self_check;
import std.digest.crc;
import std.algorithm : canFind;
import std.algorithm.sorting;
import state;
import cost;

SimpleImplicant[] greedy(uint[] F, uint[] R, char[] column_names)
{
    SimpleImplicant[] implicants = [];
    foreach (uint cube; F)
    {
        implicants ~= get_simple_implicant(cube, generate_block_matrix(cube, R), column_names);
    }
    SimpleImplicant[] temp = [];
    foreach (SimpleImplicant a; implicants)
    {
        bool already_in_temp = false;
        foreach (SimpleImplicant b; temp)
        {
            if ((a.cube & a.mask) == (b.cube & b.mask) && a.mask == b.mask)
            {
                already_in_temp = true;
                break;
            }
        }
        if (!already_in_temp)
        {
            temp ~= a;
        }
    }
    implicants = temp;

    uint[] F_remaining = F.dup;

    SimpleImplicant[] returnable = [];

    while(F_remaining.length > 0){
        SimpleImplicant best_implicant = implicants[0];
        uint[] F_remaining_after_this_pass = remove_values_matching_simple_implicant(F_remaining,best_implicant);
        foreach (SimpleImplicant test; implicants)
        {
            uint[] left_after_test = remove_values_matching_simple_implicant(F_remaining.dup,test);
            if(left_after_test.length < F_remaining_after_this_pass.length){
                best_implicant = test;
                F_remaining_after_this_pass = left_after_test;
            }
            else if(left_after_test.length == F_remaining_after_this_pass.length && 
            expression_cost([test],column_names) < expression_cost([best_implicant],column_names)){
                best_implicant = test;
                F_remaining_after_this_pass = left_after_test;
            }
        }
        returnable ~= best_implicant;
        F_remaining = F_remaining_after_this_pass;
    }
    
    return returnable;
}
