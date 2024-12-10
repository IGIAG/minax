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

import core.memory;

import std.typecons;

private struct Path
{
    SimpleImplicant[] simple_implicants;
    bool reduce(uint[] F)
    {
        uint[] cubes = F.dup;
        foreach (SimpleImplicant implicant; simple_implicants)
        {
            cubes = fast_remove_matching(cubes, implicant);
        }
        return cubes.length == 0;
    }
    uint[] remaining_cubes(uint[] F){
        uint[] cubes = F.dup;
        foreach (SimpleImplicant implicant; simple_implicants)
        {
            cubes = fast_remove_matching(cubes, implicant);
        }
        return cubes;
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
        paths ~= Path([imp]);
    }

    uint i = 0;
    while (true)
    {
        if(SHOW_PROGRESS){
            writefln("it %s | paths to process %s",i,paths.length);
        }
        Path[] next_paths = [];

        shared Path full_path;
        shared bool found_full_path = false;

        foreach (Path path; taskPool.parallel(paths, max(paths.length / taskPool.size,1)))
        {
            
            if(path.reduce(F) && path.simple_implicants.length != 0){
                synchronized {
                    full_path = cast(shared)path;
                    found_full_path = true;
                }
            }
            foreach (uint cube; path.remaining_cubes(F))
            {
                SimpleImplicant[] next_simple_implicants = fast_simple_implicants(cube, generate_block_matrix(cube, R), (
                        1 << column_names.length) - 1, column_names);
                foreach (SimpleImplicant next_simple_implicant; next_simple_implicants)
                {
                    synchronized {
                        next_paths ~= Path(path.simple_implicants ~ next_simple_implicant);
                    }
                    
    
                }
            }
        }
        synchronized {
            if(found_full_path){
            return cast(SimpleImplicant[])full_path.simple_implicants;
        }
        }
        
        if(SHOW_PROGRESS){
            writefln("it %s | filtering...",i);
        }
        
        Path[string] dup_table;
        foreach (Path path; taskPool.parallel(next_paths, max(paths.length / taskPool.size,1)))
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
        ulong bytes_freed = GC.stats().usedSize;
        if(SHOW_PROGRESS){
            writefln("cleaning up!");
        }
        
        GC.collect();
        bytes_freed -= GC.stats().usedSize;
        if(SHOW_PROGRESS){
            writefln("clear! Freed %s bytes.",bytes_freed);
        }
        
        
        paths = dup_table.values;
        i++;
    }

}
