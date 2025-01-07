module methods.systematic;
import simple_implicant;
import methods.smart;
import block_matrix;
import std.stdio;
import core.bitop;

SimpleImplicant[] systematic(uint[] F,uint[] R,char[] column_names){
    SimpleImplicant[] implicants = [];
    uint mask = cast(uint)(1 << column_names.length) - 1;
    foreach (uint cube; F)
    {
        implicants ~= get_simple_implicant(cube,generate_block_matrix(cube,R),mask,column_names);
    }
    writeln("getting matrix");
    ulong[] implicant_matrix = new ulong[F.length];
    for (int implicant_index; implicant_index < implicants.length;implicant_index++)
    {
        SimpleImplicant implicant = implicants[implicant_index];
        for(int i = 0;i < F.length;i++){
            uint cube = F[i];
            if(implicant.matches_value(cube)){
                implicant_matrix[i] = implicant_matrix[i] | (1 << implicant_index);
            }
        }
    }
    writeln("finding the best mask");
    ulong implicant_mask = 0;
    ulong best_mask  = ((cast(ulong)1) << implicants.length) - 1;
    bool found_good = false;
    while (implicant_mask <= best_mask)
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
            //found_good = true;
            writeln("THIS IS THE ONE!");
            //writefln("%b",implicant_mask);
        }
        implicant_mask++;
    }
    //writeln(implicants.length);
    foreach (ulong row; implicant_matrix)
    {
        //writefln("%b",row);
    }
    if(!found_good){
        // /throw new Error("BAD!");
    }
    


    //writeln("BEST MASK IS:");
    //writefln("%b",best_mask);

    SimpleImplicant[] returnable = [];
    writeln("unmatrix-ification");
    ulong shift = implicants.length;
    while(best_mask > 0){
        //writeln(shift);
        if((best_mask & 1) == 1){
            returnable ~= implicants[implicants.length - shift];
        }
        best_mask = best_mask >> 1;
        shift--;
    }
    //writeln(simple_implicant_to_string(returnable,column_names));
    //writeln(simple_implicant_to_string(smart_method(F,R,column_names),column_names));
    return returnable;
}