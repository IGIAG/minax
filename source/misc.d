module misc;
import std.format;
import std.random;
import simple_implicant;
import std.stdio;

struct TruthTable
{
    uint[] on_set;
    uint[] off_set;
    char[] column_names;
}

TruthTable get_random_truth_table(int seed,int columns)
{
    auto rnd = MinstdRand0(seed);

    uint[] rows = [];
    for (int i = 0; i < (1 << columns); i++)
    {
        rows ~= i;
    }
    rows = rows.randomShuffle(rnd);

    uint[] F = rows[0 .. (rows.length / 3)];
    uint[] R = rows[(rows.length / 3) .. ((rows.length * 2) / 3)];
    char[] column_names = [];
    for (int i = 0; i < columns; i++)
    {
        column_names ~= format("%s", i);
    }
    return TruthTable(F,R,column_names);
}

uint safe_shift_left(uint a,ubyte amount){
    uint r = a << amount;
    if(r <= a && amount != 0){
        throw new Exception("SHIFT OVERFLOW (UINT)");
    }
    return r;
}

ulong long_safe_shift_left(ulong a,uint amount){
    ulong r = a << amount;
    
    if(r <= a && amount != 0){
        throw new Exception("SHIFT OVERFLOW (ULONG)");
    }
    return r;
}