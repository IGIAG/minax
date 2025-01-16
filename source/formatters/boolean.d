module formatters.boolean;

import binary_matrix_utils.simple_implicant;

import std.format;

import core.bitop;

string expression_to_string(SimpleImplicant[] implicants,char[] column_names){
    string output = "";
    output ~= implicant_to_string(implicants[0],column_names);
    implicants = implicants[1..implicants.length];
    

    foreach (SimpleImplicant implicant; implicants)
    {
        output ~= " || ";
        output ~= implicant_to_string(implicant,column_names);

    }
    return output;
}
private string implicant_to_string(SimpleImplicant implicant,char[] column_names)
    {
        string returnable = "(";
        uint shiftR = 0;
        while (shiftR < 32)
        {
            if ((implicant.mask >> shiftR) % 2 == 0)
            {
                shiftR++;
                continue;
            }
            if ((implicant.cube >> shiftR) % 2 == 0)
            {
                
                returnable ~= format(" !%s ",column_names[$ - shiftR - 1]);
            }
            else
            {
                
                returnable ~= format(" %s ",column_names[$ - shiftR - 1]);
            }
            if(popcnt(implicant.mask >> shiftR + 1) > 0){
                returnable ~= "&&";
            }

            shiftR++;
        }

        return returnable ~ ")";
    }