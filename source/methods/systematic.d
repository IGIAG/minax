module methods.systematic;
import simple_implicant;
import methods.smart;
import block_matrix;
import std.stdio;
import core.bitop;
import misc;

SimpleImplicant[] systematic(uint[] F, uint[] R, char[] column_names)
{
    SimpleImplicant[] implicants = [];
    uint mask = cast(uint)(1 << column_names.length) - 1;
    foreach (uint cube; F)
    {
        implicants ~= get_simple_implicant(cube, generate_block_matrix(cube, R), mask, column_names);
    }

    /*SimpleImplicant[] temp = [];
    foreach (SimpleImplicant a; implicants)
    {
        bool already_in_temp = false;
        foreach (SimpleImplicant b; implicants)
        {
            if(b.contains(a)){
                already_in_temp = true;
                break;
            }
        }
        if(!already_in_temp){
            temp ~= a;
        }
    }*/
    //implicants = temp;

    //writeln("getting matrix");
    ulong[] implicant_matrix = new ulong[F.length];
    for (int implicant_index; implicant_index < implicants.length; implicant_index++)
    {
        SimpleImplicant implicant = implicants[implicant_index];
        for (int i = 0; i < F.length; i++)
        {
            uint cube = F[i];
            if (implicant.matches_value(cube))
            {
                ulong one = 1; //KEK
                //writeln(implicant_index);
                implicant_matrix[i] = implicant_matrix[i] | (safe_shift_left(one, cast(ubyte) implicant_index));
            }
        }
    }
    //writeln("finding the best mask");
    ulong implicant_mask = 0;
    ulong full_set = (safe_shift_left(1, cast(uint) implicants.length)) - 1;
    ulong best_mask = full_set;
    ulong[] all_masks = [];
    bool found_good = false;
    while (implicant_mask <= full_set)
    {
        ulong[] matrix = implicant_matrix.dup;
        for (ulong i = 0; i < matrix.length; i++)
        {
            matrix[i] = matrix[i] & implicant_mask;
        }
        for (ulong i = 0; i < matrix.length; i++)
        {
            matrix[i] = matrix[i] > 0;
        }
        ulong sum = matrix.length > 0 ? matrix[0] : 0;
        for (ulong i = 1; i < matrix.length; i++)
        {
            sum = matrix[i] & sum;
        }
        if (sum > 0 && popcnt(best_mask) >= popcnt(implicant_mask))
        {
            best_mask = implicant_mask;
            found_good = true;
            all_masks ~= best_mask;
            //writeln("THIS IS THE ONE!");
            //writefln("%b",implicant_mask);
        }
        implicant_mask++;
    }
    //writeln(implicants.length);
    foreach (ulong row; implicant_matrix)
    {
        //string topad = format("%b",row);
        //writefln("%s",row);
    }
    if (!found_good)
    {
        throw new Error("NO VALID PATH!");
    }
    else
    {
        //writefln("Found mask %b",best_mask);
    }

    //writeln("BEST MASK IS:");
    //writefln("%b",best_mask);

    SimpleImplicant[] returnable = [];
    //writeln("unmatrix-ification");
    ulong shift = implicants.length;
    while (best_mask > 0)
    {
        //writeln(shift);
        if ((best_mask & 1) == 1)
        {
            returnable ~= implicants[implicants.length - shift];
        }
        best_mask = best_mask >> 1;
        shift--;
    }

    foreach (ulong good_mask; all_masks)
    {
        if (popcnt(good_mask) == returnable.length)
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
            TruthTable truth_table = TruthTable(F.dup,R.dup,column_names.dup);
            ulong offsets_length = truth_table.off_set.length;
            foreach (SimpleImplicant implicant; r1)
            {
                truth_table.on_set = remove_values_matching_simple_implicant(truth_table.on_set, implicant);
                truth_table.off_set = remove_values_matching_simple_implicant(truth_table.off_set,implicant);
                assert(truth_table.off_set.length == offsets_length);
            }
            assert(truth_table.on_set.length == 0);
            writeln(simple_implicant_to_string(r1,column_names));
        }
        
    }

    //writeln(simple_implicant_to_string(returnable,column_names));
    //writeln(simple_implicant_to_string(smart_method(F,R,column_names),column_names));
    return returnable;
}
