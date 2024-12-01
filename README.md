# Minax
## Prosty program do minimalizacji funkcji booleowskich
*Krzysztof Kubicz 01.12.2024*

## Instrukcja
1. Dane do programu można załadować z:
    - pliku
    - wejścia standardowego
2. Aby załadować z pliku należy użyć odpowiedniego formatu. Przykładowy plik znajduje się w repozytorium pod nazwą `testfile.txt`.
    - każda sekcja jest oddzielona pustym wierszem
    - pierwsza linijka pliku wybiera tryb należy tam wpisać `BINARY` lub `DECIMAL` (w trybie decimal podajemy nr. wierszów)
    - drugi wiersz definiuje nazwy parametrów (kolumn)
    - następna sekcja definiuje zbiór F (on-set), czyli kombinacje parametrów gdzie funkcja zwraca `1`
    - ostatnia sekcja definiuje zbiór R (off-set), czyli kombinacje gdzie funkcja zwraca `0`.
    - Aby wczytać plik, podaj jego ścieżkę w parametrze. Przykład:
    `minax.exe testfile.txt`
    - Przykładowy plik:
        ```
        BINARY

        a,b

        00
        10

        01
        11
        ```
        Definiuje funkcję o tabeli prawdy:
        | a | b | f |
        |---|---|---|
        | 0 | 0 | 1 |
        | 0 | 1 | 0 |
        | 1 | 0 | 1 |
        | 1 | 1 | 0 |
3. Aby wczytać dane z wejścia standardowego, niepodawaj parametru.

## Ograniczenia:

- Maksymalna ilość parametrów: 32
- Użycie metody heurystycznej, uzyskane wyrażenie nie musi być w 100% optymalne.
## Gotowe binarki:
- Gotowe binarki są dostępne [tutaj](https://github.com/IGIAG/minax/releases/tag/binarki)
## Kompilacja:

Wymagania:
-   Program DUB [https://github.com/dlang/dub](https://github.com/dlang/dub)

Proces:
- W katalogu projektu należy wykonać komendę `dub build`, a plik wykonywalny dla
twojej platformy pojawi się w tym samym katalogu.
