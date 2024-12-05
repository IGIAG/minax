import std.stdio;
import std.range;
import simple_implicant;
import block_matrix;
import input_output;
import methods.heuristic;
import methods.smart;
import methods.none;
import darg;

struct Options
{
    @Option("help", "h")
    @Help("Wyświetla tę wiadomość")
    OptionFlag help;

    @Argument("file",Multiplicity.optional)
    @Help("Opcjonalna ścieżka do pliku")
    string path = "";
	@Option("method","m")
    @Help("Opcjonalna metoda do minimalizacji (HEURISTIC,SMART,NONE)")
    string method = "";
}

immutable usage = usageString!Options("example");
immutable help = helpString!Options;

void main(string[] args)
{
	writeln(import("intro.txt"));

	Options options;

    try
    {
        options = parseArgs!Options(args[1 .. $]);
    }
    catch (ArgParseError e)
    {
        writeln(e.msg);
        writeln(usage);
        return;
    }
    catch (ArgParseHelp e)
    {
        writeln(usage);
        write(help);
        return;
    }
	
	char[] column_names = [];
	uint[] F = [];
	uint[] R = [];
	if (options.path == "")
	{
		input_output.read_from_input(column_names, F, R);
	}
	else
	{
		input_output.read_from_file(options.path, column_names, F, R);
	}
	SimpleImplicant[] simple_implicants;
	switch (options.method){
		case "SMART":
			simple_implicants = smart_method(F,R,column_names);
			break;
		case "HEURISTIC":
			simple_implicants = heuristic_method(F,R,column_names);
			break;
		case "NONE":
			simple_implicants = minterms(F,R,column_names);
			break;
		default:
			simple_implicants = heuristic_method(F,R,column_names);
			break;
	}
	

	writefln("Uproszczone wyrazenie booleowskie: %s", simple_implicant_to_string(simple_implicants,column_names));
}
