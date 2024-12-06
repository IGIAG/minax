module methods.systemic;

import simple_implicant;

import block_matrix;

import std.stdio;

SimpleImplicant[] systemic(uint[] F,uint[] R,char[] column_names){
    SimpleImplicant[] returnable = [];
    uint mask = cast(uint)(1 << column_names.length) - 1;
    foreach (uint row; F)
    {
        returnable ~= get_simple_implicant(row,generate_block_matrix(row,R),mask,column_names);
    }
    if(returnable.length > 128){
        throw new Exception("Function too large!!!");
    }
    ulong max_combination_mask = (1 << returnable.length) - 1;

    ulong combination_mask = 0;

    SimpleImplicant[] best_combination = returnable.dup;

    while(combination_mask < max_combination_mask){
        SimpleImplicant[] combination = parse_combination_mask(returnable,combination_mask);

        if(is_combination_valid(F.dup,combination)){
            if(combination.length < best_combination.length){
                best_combination = combination;
            }
        }

        //writefln("%s",combination);

        combination_mask++;
    }



    return best_combination;
}
SimpleImplicant[] parse_combination_mask(SimpleImplicant[] source,ulong combination_mask){
    SimpleImplicant[] returnable = [];
    int shift = 0;
    while((combination_mask >> shift) > 0){
        if((combination_mask >> shift) % 2 == 1){
            returnable ~= source[shift];
        }
        shift++;
    }
    return returnable;
}

bool is_combination_valid(uint[] F,SimpleImplicant[] implicants){
    foreach (SimpleImplicant implicant; implicants)
    {
        F = remove_values_matching_simple_implicant(F,implicant);
    }
    return F.length == 0;
}