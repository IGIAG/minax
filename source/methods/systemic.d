module methods.systemic;

import simple_implicant;

import block_matrix;

import methods.none;

import std.stdio;

import std.functional;

SimpleImplicant[] systemic(uint[] F,uint[] R,char[] column_names){
    writeln("UWAGA! TA METODA JEST EKSPERYMENTALNA.");
    if(column_names.length > 5){
        writeln("\x1B[0;31mPODANO WIĘCEJ NIŻ 5 KOLUMN. DLA TEJ METODY TO ZŁY POMYSŁ!\x1B[0;37m");
        writeln("\x1B[0;33mWYMAGANIE POTWIERDZENIE [ENTER]\x1B[0;37m");
        readln();
    }
    return recurrance(F,R,column_names,0);
}

alias fast_recurrance = memoize!(recurrance,5000_000);

private SimpleImplicant[] recurrance(uint[] F,uint[] R,char[] column_names,uint depth){
    SimpleImplicant[] next_simple_impicants = [];
    foreach (uint cube; F)
    {   
        next_simple_impicants ~= fast_simple_implicants(cube,generate_block_matrix(cube,R),(1 << column_names.length) - 1,column_names);
    }
    if(next_simple_impicants.length == 0){
        return [];
    }

    if(next_simple_impicants.length == 1){
        return next_simple_impicants;
    }
    uint best_case = cast(uint)F.length;
    SimpleImplicant[] best_path = [];
    uint i = 0;
    foreach (SimpleImplicant next_simple_implicant; next_simple_impicants)
    {
        if(depth == 0){
            writefln("%s %% (%s/%s)",i*100/next_simple_impicants.length,i,next_simple_impicants.length);
        }
        SimpleImplicant[] path = fast_recurrance(fast_remove_matching(F,next_simple_implicant),R,column_names,depth + 1);
        if(cast(uint)path.length < best_case){
            
            best_path = path;
            best_path ~= next_simple_implicant;
            best_case = cast(uint)best_path.length;
        }
        i++;
    }
    return best_path;
}