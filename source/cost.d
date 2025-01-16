module cost;

import binary_matrix_utils.simple_implicant;

import core.bitop;

uint expression_cost(SimpleImplicant[] expression,char[] column_names){
    uint not_gates = 0;
    uint and_gates = cast(uint)expression.length;
    uint or_gates = cast(uint)expression.length - 1;
    uint wires = 0;
    uint column_mask = 0;

    foreach (SimpleImplicant im; expression)
    {   
        not_gates += popcnt(((~im.cube) & im.mask));
        wires += popcnt(im.mask);
        wires += popcnt(((~im.cube) & im.mask));
        column_mask = column_mask | im.mask;
        wires++;
    }
    wires += popcnt(column_mask);

    return not_gates + and_gates + or_gates + wires;
}