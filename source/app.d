import std.stdio;
import std.range;
import simple_implicant;
import block_matrix;
import std.random;
import input_output;

void main(string[] args)
{
	writeln(import("intro.txt"));
	char[] column_names = [];
	uint[] F = [];
	uint[] R = [];
	if (args.length == 1)
	{
		input_output.read_from_input(column_names, F, R);
	}
	else
	{
		writefln("Odczytywanie z pliku: %s\n",args[1]);
		input_output.read_from_file(args[1], column_names, F, R);
	}

	SimpleImplicantValue[][] simple_implicants = [];
	uint iteration = 0;
	while (F.length > 0 && iteration < uint.max)
	{
		uint cube = F[0];
		uint[] block_matrix = generate_block_matrix(cube, R);
		try
		{
			SimpleImplicantValue[] cubes_simple_implicant = get_simple_implicant(cube, block_matrix, cast(
					int)(column_names.length * column_names.length), column_names);
			simple_implicants ~= cubes_simple_implicant;
			F = simple_implicant.remove_values_matching_simple_implicant(F, cubes_simple_implicant);
		}
		catch (Exception e)
		{
			F = F.randomShuffle(); //if couldn't find simple implicant for cube, shuffle array to get better cube at the begining
		}
		iteration++;
		writeln(iteration);
	}
	if (iteration == uint.max)
	{
		writeln("Przekroczono limit iteracji w głównej pętli");
		return;
	}
	string[] stringed_simple_implicants = [];
	foreach (SimpleImplicantValue[] simple_implicant; simple_implicants)
	{
		stringed_simple_implicants ~= simple_implicant_to_string(simple_implicant, column_names);
	}
	writefln("Uproszczone wyrazenie booleowskie: %s", stringed_simple_implicants.join(" + "));
}
