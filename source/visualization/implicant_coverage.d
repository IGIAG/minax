module visualization.implicant_coverage;

import binary_matrix_utils.simple_implicant;

const string[] colors = ["red",  "green",  "orange",  "blue",  "magenta", "cyan", "lgrey", 
        "grey", "lred", "lgreen", "yellow", "lblue", "lmagenta", "lcyan"
    ];

void render_coverage(SimpleImplicant[] implicants,uint[] F,char[] column_names){
    import consolecolors;
    import std.range : padLeft;
    import std.format;
    string[SimpleImplicant] color_map;
    

    cwriteln("VISUALIZATION:\n");
    cwriteln("Legend:\n");

    for (int i = 0;i<implicants.length;i++)
    {
        string color = colors[i % $];
        color_map[implicants[i]] = color;
        cwritefln("I%s : <on_%s>%s</on_%s>",i,color,implicants[i].to_string(column_names),color);
    }
    
    cwriteln("");

    cwrite(column_names ~ "|");
    for(int x = 0;x < implicants.length;x++)
    {
        cwritef("I%s ",x);
    }
    cwrite("\n");

    foreach (uint row; F)
    {
        cwrite(format("%b|",row).padLeft('0',column_names.length + 1));
        for(int x = 0;x < implicants.length;x++){
            SimpleImplicant i = implicants[x];
            if(i.matches_value(row)){
                cwritef("<on_%s>%s</on_%s> ",color_map[i],"".padLeft(' ',format("I%s",x).length),color_map[i]);
            }
            else {
                cwritef("%s ","".padLeft(' ',format("I%s",x).length));
            }
        }
        cwrite("\n");
    }
}
