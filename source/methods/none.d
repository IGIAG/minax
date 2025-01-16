module methods.none;

import binary_matrix_utils.simple_implicant;

import std.stdio;

SimpleImplicant[] minterms(uint[] F,uint[] R,char[] column_names){
    SimpleImplicant[] returnable = [];
    uint mask = cast(uint)(1 << column_names.length) - 1;
    foreach (uint row; F)
    {
        returnable ~= SimpleImplicant(row,mask);
    }
    return returnable;
}