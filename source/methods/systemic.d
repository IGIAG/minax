module methods.systemic;

import simple_implicant;

import block_matrix;

import methods.heuristic;

import std.stdio;
import std.math;

SimpleImplicant[] systemic(uint[] F,uint[] R,char[] column_names){
    return recurrance(F,R,column_names,0);
}
private SimpleImplicant[] recurrance(uint[] F,uint[] R,char[] column_names,uint depth){
    SimpleImplicant[] next_simple_impicants = [];
    foreach (uint cube; F)
    {   
        next_simple_impicants ~= get_simple_implicant(cube,generate_block_matrix(cube,R),(1 << column_names.length) - 1,column_names);
    }
    

    if(next_simple_impicants.length == 1){
        return next_simple_impicants;
    }

    uint best_case = cast(uint)F.length;
    SimpleImplicant[] best_path = [];

    foreach (SimpleImplicant next_simple_implicant; next_simple_impicants)
    {
        SimpleImplicant[] path = recurrance(remove_values_matching_simple_implicant(F,next_simple_implicant),R,column_names,depth + 1);
        if(cast(uint)path.length < best_case){
            //writefln("Found new best path: %s | score %s",best_path,path.length);
            best_path = path;
            best_path ~= next_simple_implicant;
            best_case = cast(uint)best_path.length;
        }
    }
    //writefln("RETURNING!!!");
    return best_path;
}

