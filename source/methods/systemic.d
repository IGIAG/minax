module methods.systemic;

import simple_implicant;

import block_matrix;

import methods.heuristic;

import methods.none;

import std.stdio;

import std.functional;

import std.algorithm;

import std.array;

import std.parallelism;

import std.digest.crc;

import std.algorithm.sorting;

import state;

private struct Path
{
    SimpleImplicant[] simple_implicants;
    uint[] remaining_cubes = [];
    bool reduce()
    {
        foreach (SimpleImplicant implicant; simple_implicants)
        {
            remaining_cubes = remove_values_matching_simple_implicant(remaining_cubes, implicant);
        }
        return remaining_cubes.length == 0;
    }
}

SimpleImplicant[] systemic(uint[] F, uint[] R, char[] column_names)
{
    SimpleImplicant[] simple_implciants = [];

    foreach (uint cube; F)
    {
        simple_implciants ~= get_simple_implicant(cube,generate_block_matrix(cube,R),(1 << column_names.length) - 1,column_names);
    }

    Path[] paths = [];

    foreach (SimpleImplicant imp; simple_implciants)
    {
        paths ~= Path([imp],F.dup);
    }

    uint i = 0;
    while (true)
    {
        foreach (Path path; paths)
        {
            if (path.reduce() && path.simple_implicants.length != 0)
            {
                return path.simple_implicants;
            }
        }
        if(SHOW_PROGRESS){
            writefln("it %s | paths to process %s",i,paths.length);
        }
        Path[] next_paths = [];
        foreach (Path path; taskPool.parallel(paths, 4))
        {
            path.reduce();
            foreach (uint cube; path.remaining_cubes)
            {
                SimpleImplicant[] next_simple_implicants = fast_simple_implicants(cube, generate_block_matrix(cube, R), (
                        1 << column_names.length) - 1, column_names);
                foreach (SimpleImplicant next_simple_implicant; next_simple_implicants)
                {
                    synchronized {
                        next_paths ~= Path(path.simple_implicants ~ next_simple_implicant, F.dup);
                    }
                    
    
                }

            }
        }
        if(SHOW_PROGRESS){
            writefln("it %s | filtering...",i);
        }
        
        Path[string] dup_table;
        foreach (Path path; taskPool.parallel(next_paths, 1))
        {
            uint[] implicant_values = [];
            path.simple_implicants.sort!((a,b) => (a.cube + a.mask) < (b.cube + b.mask))();
            foreach (SimpleImplicant imp; path.simple_implicants)
            {
                implicant_values ~= imp.cube;
                implicant_values ~= imp.mask;
            }
            synchronized {
                dup_table[crcHexString(crc32Of(implicant_values))] = path;
            }
            
        }
        if(SHOW_PROGRESS){
            writefln("it %s done. full_next_paths %s | unique %s",i,next_paths.length,dup_table.values.length);
        }
        
        paths = dup_table.values;
        i++;
    }

}
