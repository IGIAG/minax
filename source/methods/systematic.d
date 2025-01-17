module methods.systematic;
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

import combinations;

SimpleImplicant[] systematic_simple(uint[] F, uint[] R, char[] column_names)
{
    return systematic(F, R, column_names)[0];
}

SimpleImplicant[][] systematic(uint[] F, uint[] R, char[] column_names)
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
    

    if(implicants.length > 63){
        throw new Exception("More than 64 implicants found. Can't fit into matrix. Please use a different method!");
    }

    ulong[] implicant_matrix = new ulong[F.length];
    for (int implicant_index; implicant_index < implicants.length; implicant_index++)
    {
        SimpleImplicant implicant = implicants[implicant_index];
        for (int i = 0; i < F.length; i++)
        {
            uint cube = F[i];
            if (implicant.matches_value(cube))
            {
                
                implicant_matrix[i] = implicant_matrix[i] | (long_safe_shift_left(1L, cast(ubyte) implicant_index));
            }
        }
    }

    if(state.VISUALISE_ALL){
        import std.stdio;
        writeln("THIS IS FOR ALL IMPLICANTS: ");
        import visualization.implicant_coverage;
        render_coverage(implicants,F,column_names);
    }

    ulong implicant_mask = 0;
    ulong full_set = (long_safe_shift_left(1L, cast(uint) implicants.length)) - 1;
    ulong best_mask = full_set;
    ulong[] all_masks = [];
    bool found_good = false;

    for (int bits_set = 0; bits_set <= implicants.length; bits_set++)
    {
        ulong[] masks = binary_combinations(full_set, bits_set);
        if(state.SHOW_PROGRESS) {
            writefln("Checking %s bit solutions... (%s possibilities)",bits_set,masks.length);
        }
        

        ulong[] valid_masks = [];

        foreach (ulong potential_valid_mask; masks)
        {
            ulong[] matrix = implicant_matrix.dup;
            for (int i = 0; i < matrix.length; i++)
            {
                matrix[i] = matrix[i] & potential_valid_mask;
            }
            for (int i = 0; i < matrix.length; i++)
            {
                matrix[i] = matrix[i] > 0;
            }
            ulong sum = matrix.length > 0 ? matrix[0] : 0;
            for (int i = 1; i < matrix.length; i++)
            {
                sum = matrix[i] & sum;
            }
            if (sum > 0)
            {
                valid_masks ~= potential_valid_mask;
            }
        }
        if (valid_masks.length > 0)
        {
            found_good = true;
            all_masks = valid_masks;
            break;
        }
    }
    assert(found_good);

    SimpleImplicant[][] returnable_all = [];
    foreach (ulong good_mask; all_masks)
    {

        SimpleImplicant[] r1 = [];
        //writeln("unmatrix-ification");
        ulong s = implicants.length;
        while (good_mask > 0)
        {
            //writeln(shift);
            if ((good_mask & 1) == 1)
            {
                r1 ~= implicants[implicants.length - s];
            }
            good_mask = good_mask >> 1;
            s--;
        }
        verify_expression(F.dup, R.dup, column_names, r1);
        returnable_all ~= r1;

    }
    //writeln(simple_implicant_to_string(returnable,column_names));
    //writeln(simple_implicant_to_string(smart_method(F,R,column_names),column_names));
    return returnable_all;
}
