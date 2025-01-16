import std.stdio;
import std.range;

import std.format;
import simple_implicant;
import block_matrix;
import input_output;
import methods.heuristic;
import methods.smart;
import methods.systemic;
import methods.none;
import darg;
import state;
import methods.systematic;
import methods.greedy;
import formatters.boolean;
import formatters.budyns;
import consolecolors;

import core.exception;
import misc;

struct Options
{
	@Option("help", "h")
	@Help("Wyświetla tę wiadomość")
	OptionFlag help;

	@Argument("file", Multiplicity.optional)
	@Help("Opcjonalna ścieżka do pliku")
	string path = "";
	@Option("method", "m")
	@Help(generateHelpMethodsList)  //This returns an error
	string method = "GREEDY";
	@Option("cap", "c")
	@Help("Tylko dla metody FULL. Opcjonalny parametr, ogranicza przeszukiwane kombinacje implikantów. Ustawnienie tego parametru neguje systematyczność tej metody ale ma duże zyski wydajnościowe")
	int full_cap = 0;
	@Option("show-progress", "s")
	@Help("(Działa tylko dla metody FULL) Wypisuje nr. iteracji oraz ilość znalezionych ścieżek w czasie rzeczywistym.")
	bool show_progress = false;
	@Option("format", "f")
	@Help(generateHelpFormattersList)
	string format = "DEFAULT";
}

string generateHelpMethodsList()
{
	return format("Opcjonalna metoda do minimalizacji %s", METHOD_MAP.keys);
}

string generateHelpFormattersList()
{
	return format("Zmienia format wyjściowych funkcji. Dostąpne %s", FORMATER_MAP.keys);
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
	"DEFAULT": &simple_implicant.simple_implicant_to_string, //Standard ( + x')
	"BUDYN": &formatters.budyns.expression_to_string, // ~ +
	"CODE": &formatters.boolean.expression_to_string // && || !
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

	writefln("Solutions:");
	foreach (SimpleImplicant[] key; solutions)
	{
		writefln("%s", formater(key, column_names));
	}

}
