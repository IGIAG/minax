import std.stdio;
import std.range;
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
import formatters.budyns;
import consolecolors;

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
	@Help("Opcjonalna metoda do minimalizacji (HEURISTIC,SMART,NONE,GREEDY,BRUTE,SYSTEMATIC)")
	string method = "GREEDY";
	@Option("cap", "c")
	@Help("Tylko dla metody FULL. Opcjonalny parametr, ogranicza przeszukiwane kombinacje implikantów. Ustawnienie tego parametru neguje systematyczność tej metody ale ma duże zyski wydajnościowe")
	int full_cap = 0;
	@Option("show-progress", "s")
	@Help("(Działa tylko dla metody FULL) Wypisuje nr. iteracji oraz ilość znalezionych ścieżek w czasie rzeczywistym.")
	bool show_progress = false;
	@Option("budyn-format", "b")
	bool budyn_format = false;

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
	switch (options.method)
	{
	case "SMART":
		simple_implicants = smart_method(F, R, column_names);
		break;
	case "HEURISTIC":
		simple_implicants = heuristic_method(F, R, column_names);
		break;
	case "NONE":
		simple_implicants = minterms(F, R, column_names);
		break;
	case "GREEDY":
		simple_implicants = greedy(F, R, column_names);
		break;
	case "BRUTE":
		if (options.show_progress)
		{
			SHOW_PROGRESS = true;
		}
		state.FULL_CAP = options.full_cap;
		simple_implicants = systemic(F, R, column_names);
		break;
	case "SYSTEMATIC":
		SimpleImplicant[][] results = systematic(F, R, column_names);
		writefln("Rozwiązania");
		foreach (SimpleImplicant[] key; results)
		{
			if (options.budyn_format)
			{
				writefln("%s", expression_to_string(key));
			}
			else
			{
				writefln("%s", simple_implicant_to_string(key, column_names));
			}

		}
		return;
	case "":
		simple_implicants = heuristic_method(F, R, column_names);
		break;
	default:
		throw new Exception("NOT A VALID METHOD! CHECK HELP PAGE (--help)");
		break;
	}
	if (options.budyn_format)
	{
		writefln("Uproszczone wyrazenie booleowskie: %s", expression_to_string(
				simple_implicants));
	}
	else
	{
		writefln("Uproszczone wyrazenie booleowskie: %s", simple_implicant_to_string(
				simple_implicants, column_names));
	}

}
