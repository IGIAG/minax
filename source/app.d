import std.stdio;
import std.range;
import simple_implicant;
import block_matrix;
import input_output;
import heuristic;

import smart;

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
	SimpleImplicant[] smart_simple_implicants = smart.smart_method(F.dup,R.dup,column_names.dup);
	SimpleImplicant[] simple_implicants = heuristic.heuristic_method(F,R,column_names);
	
	
	string[] stringed_simple_implicants = [];
	foreach (SimpleImplicant simple_implicant; simple_implicants)
	{
		stringed_simple_implicants ~= simple_implicant_to_string(simple_implicant, column_names);
	}
	string[] stringed_smart_simple_implicants = [];
	foreach (SimpleImplicant simple_implicant; smart_simple_implicants)
	{
		stringed_smart_simple_implicants ~= simple_implicant_to_string(simple_implicant, column_names);
	}
	writefln("Uproszczone wyrazenie booleowskie (h): %s", stringed_simple_implicants.join(" + "));
	writefln("Uproszczone wyrazenie booleowskie (s): %s", stringed_smart_simple_implicants.join(" + "));
}
