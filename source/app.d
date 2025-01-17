import std.stdio;
import std.range;

import std.format;
import binary_matrix_utils.simple_implicant;
import binary_matrix_utils.block_matrix;
import input_output;
import methods.heuristic;
import methods.smart;
import methods.systemic;
import methods.none;
import darg;
import state;
import methods.systematic;
import methods.greedy;
import formatters.standard;
import formatters.boolean;
import formatters.budyns;
import formatters.math;
import formatters.standard_overline;
import consolecolors;
import core.exception;
import binary_matrix_utils.misc;

struct Options
{
	@Option("help", "h")
	@Help("Shows this message.")
	OptionFlag help;

	@Argument("file", Multiplicity.optional)
	@Help("Optional - Input file path")
	string path = "";
	@Option("method", "m")
	@Help(generateHelpMethodsList)
	string method = "GREEDY";
	@Option("cap", "c")
	@Help(import("help/cap_help.txt"))
	int full_cap = 0;
	@Option("show-progress", "s")
	@Help("Optional - For supported methods, print real-time progress info.")
	bool show_progress = false;
	@Option("format", "f")
	@Help(generateHelpFormattersList)
	string format = "DEFAULT";

	@Option("visualization", "v")
	@Help("Shows a visualization of how implicants cover F (ON-SET)")
	OptionFlag visualization;
}

string generateHelpMethodsList()
{
	return format("Optional - Method to use. %s", METHOD_MAP.keys);
}

string generateHelpFormattersList()
{
	return format("Optional - Format to use. %s", FORMATER_MAP.keys);
}

immutable usage = usageString!Options("minax");
immutable help = helpString!Options;

void main(string[] args)
{
	try
	{
		_main(args);
	}
	catch (Exception ex)
	{
		cwritefln("<lred>ERROR</lred> %s", ex.message);
	}
}

alias Method = SimpleImplicant[][]function(uint[], uint[], char[]);

const Method[string] METHOD_MAP = [
	"SMART": &wrap1DFunction!smart_method,
	"HEURISTIC": &wrap1DFunction!heuristic_method,
	"NONE": &wrap1DFunction!minterms,
	"GREEDY": &wrap1DFunction!greedy,
	"BRUTE": &wrap1DFunction!systemic,
	"SYSTEMATIC": &systematic
];

alias Formater = string function(SimpleImplicant[], char[]);

const Formater[string] FORMATER_MAP = [
	"DEFAULT": &formatters.standard.simple_implicant_to_string, //Standard ( + x')
	"OVERLINE": &formatters.standard_overline.simple_implicant_to_string, //Standard ( + x‾)
	"BUDYN": &formatters.budyns.expression_to_string, // ~ +
	"CODE": &formatters.boolean.expression_to_string, // && || !
	"MATH": &formatters.math.expression_to_string // && || !
];

SimpleImplicant[][] wrap1DFunction(alias func)(uint[] F, uint[] R, char[] column_names)
{
	return [func(F, R, column_names)];
}

void _main(string[] args)
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
	Method method;
	try{
		method = METHOD_MAP[options.method];
	}
	catch(RangeError err){
		writeln("Metoda nie zdefiniowana (--help)");
		return;
	}

	Formater formater;
	try{
		formater = FORMATER_MAP[options.format];
	}
	catch(RangeError err){
		writeln("Format nie zdefiniowany (--help)");
		return;
	}

	if (options.show_progress)
	{
		SHOW_PROGRESS = true;
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

	SimpleImplicant[][] solutions = method(F, R, column_names);

	SimpleImplicant[] cheapest = solutions[0];

	

	writefln("Solutions:");
	foreach (SimpleImplicant[] key; solutions)
	{
		import cost;
		writefln("%s", formater(key, column_names));
		if(expression_cost(key,column_names) < expression_cost(cheapest,column_names)){
			cheapest = key;
		}
		if(options.visualization == OptionFlag.yes){
			import visualization.implicant_coverage;
			writeln();
    		render_coverage(key,F,column_names);
			writeln();
		}
	}
	if(solutions.length != 1){
		cwritefln("<lgreen>CHEAPEST</lgreen> %s", formater(cheapest, column_names));
	}
	
	



}
