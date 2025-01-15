module methods.systemic;

import simple_implicant;

import block_matrix;

import std.stdio;

import std.algorithm;

import std.array;

import std.parallelism;

import std.digest.murmurhash;

import std.algorithm.sorting;

import std.functional;

import state;

import std.typecons;

import consolecolors;

private struct Path
{
    SimpleImplicant[] simple_implicants;
    ubyte[4] get_hash(){
        simple_implicants.sort!((a,b) => (a.cube != b.cube) ? a.cube > b.cube : a.mask > b.mask);
        MurmurHash3!32 hasher;
        foreach (SimpleImplicant i ; simple_implicants)
        {
            hasher.put((cast(ubyte*) &i.cube)[0..i.cube.sizeof]);
            hasher.put((cast(ubyte*) &i.mask)[0..i.mask.sizeof]);
        }
        
        return hasher.finish();
    }
    bool is_complete(uint[] F)
    {
        return remaining_cubes(F) == 0;
    }
    
    uint remaining_cubes(uint[] F){
        uint[] cubes = F.dup;
        foreach (SimpleImplicant implicant; simple_implicants)
        {
            cubes = fast_remove_matching(cubes, implicant);
        }
        return cast(uint)cubes.length;
    }
}

SimpleImplicant[] systemic(uint[] F, uint[] R, char[] column_names)
{
    
    const SimpleImplicant[] simple_implicants = get_base_simple_implicants(F,R,column_names);

    Path[] paths;

    foreach (SimpleImplicant i ; simple_implicants)
    {
        paths ~= Path([i]); 
    }
    uint i = 0;
    while (true)
    {
        if(state.SHOW_PROGRESS){
            if(paths.length == state.FULL_CAP){
                cwritefln("it %s | paths <lred>%s</lred> capped | implicants remaining to check %s",i, paths.length ,simple_implicants.length - i);
            }
            else {
                writefln("it %s | paths %s | implicants remaining to check %s",i, paths.length ,simple_implicants.length - i);
            }
        }
        Nullable!Path return_path;
        foreach (Path path; taskPool.parallel(paths))
        {
            if(path.is_complete(F)){
                synchronized {
                    return_path = path;
                }
            }
        }
        if(!return_path.isNull()){
            return return_path.get().simple_implicants;
        }

        Path[ubyte[4]] next_paths; 

        foreach (Path path; paths)
        {
            foreach (SimpleImplicant si; simple_implicants)
            {
                if(!path.simple_implicants.canFind(si)){
                    Path pt = Path(path.simple_implicants.dup ~ si);
                    //synchronized {
                        next_paths[pt.get_hash()] = pt;
                    //}
                }
            }
        }

        paths = next_paths.values;

        paths.sort!((a,b) => a.remaining_cubes(F) < b.remaining_cubes(F));
        if(state.FULL_CAP > 1){
            paths = paths[0..min(state.FULL_CAP,paths.length)];
        }

        i++;


    }

}
private SimpleImplicant[] get_base_simple_implicants(uint[] F,uint[] R,char[] column_names){
    SimpleImplicant[] simple_implciants = [];

    foreach (uint cube; F)
    {
        simple_implciants ~= get_simple_implicant(cube, generate_block_matrix(cube, R), column_names);
    }
    return simple_implciants;
}