module formatters.budyns;

import binary_matrix_utils.simple_implicant;

import std.format;

string expression_to_string(SimpleImplicant[] implicants,char[] column_names){
    string output = "";
    output ~= implicant_to_string(implicants[0]);
    implicants = implicants[1..implicants.length];
    

    foreach (SimpleImplicant implicant; implicants)
    {
        output ~= " + ";
        output ~= implicant_to_string(implicant);

    }
    return output;
}
private string implicant_to_string(SimpleImplicant implicant)
    {
        string returnable = "";
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
                returnable ~= format("~x%s",shiftR);
            }
            else
            {
                returnable ~= format("x%s",shiftR);
            }

            shiftR++;
        }

        return returnable;
    }