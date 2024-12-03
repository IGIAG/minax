module smart;

import simple_implicant;

import block_matrix;

import core.bitop : popcnt;

import std.stdio;
import std.string;

import std.random;

struct Record {
    SimpleImplicant implicant;
    uint covered;
}

SimpleImplicant[] smart_method(uint[] F, uint[] R, char[] column_names)
{
    SimpleImplicant[] returnable;
    SimpleImplicant[uint] coverage_map;
    foreach (uint cube; F)
    {
        SimpleImplicant[] implicants = get_simple_implicant(cube, generate_block_matrix(cube, R), 2 << column_names.length, column_names);
        foreach (SimpleImplicant implicant; implicants)
        {
            uint coverage = cast(uint)(F.length - remove_values_matching_simple_implicant(F.dup,implicant).length);
            coverage_map[coverage] = implicant;
        }
    }
    SimpleImplicant best;
    uint best_coverage = 0;

    foreach (key; coverage_map.keys)
    {
        if(key > best_coverage){
            best = coverage_map[key];
            best_coverage = key;
        }
    }
    writeln(coverage_map);
    if(F.length == 0){
        return [];
    }
    return smart_method(remove_values_matching_simple_implicant(F.dup,best),R,column_names) ~ best;

}
