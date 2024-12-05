module methods.none;

import simple_implicant;

import std.stdio;

SimpleImplicant[] minterms(uint[] F,uint[] R,char[] column_names){
    SimpleImplicant[] returnable = [];
    uint mask = 0b0;
    for(int i = 0;i < cast(long)column_names.length - 1;i++){
        mask = mask << 1;
        mask++;
    }
    foreach (uint row; F)
    {
        returnable ~= SimpleImplicant(row,mask);
    }
    return returnable;
}