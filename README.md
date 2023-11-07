Sure, here's the previous content formatted as a Markdown document:


# CFG Processor

## Introduction

The Context-Free Grammar (CFG) Processor is a Dart project designed to facilitate the handling and transformation of Context-Free Grammars. This tool provides functionality to parse, simplify, and convert CFGs to Chomsky Normal Form (CNF). Whether you are working on language recognition, formal language theory, or syntax analysis, this CFG Processor can streamline your workflow.

## Features

### Define Your CFG

You can define your CFG directly in the Dart code. Here's an example:

```dart
Map<String, List<String>> cfg = {};
List<String> nullableHeads = [];
bool canRemoveMoreNullables = false;
String input = '''
    S -> aS | SS | bA
    A -> BB
    B -> ab | aAbC | aAb | CC
    C -> ε
  ''';
```

### Simplification and Conversion

The CFG Processor offers a series of functions to simplify and convert your CFG:

- **Adding Start State**: The program adds a new start state "S0" to the CFG to simplify operations.

- **Removing Non-Generating Productions**: It removes production rules that cannot generate terminal strings.

- **Removing Non-Reachable Productions**: Eliminates production rules that cannot be reached from the start symbol.

- **Removing Nullables**: The program identifies nullable non-terminal symbols and iteratively removes them from the CFG.

- **Removing Unit Productions**: Eliminates unit productions, where a non-terminal symbol directly produces another non-terminal symbol.

- **Chomsky Normal Form (CNF) Conversion**: Converts the CFG into Chomsky Normal Form, where each production rule is either in the form "A -> a" (terminal symbol) or "A -> BC" (two non-terminals). It involves introducing new variables for terminals and unit productions.

### Output

The project outputs the simplified CFG and the CFG in Chomsky Normal Form (CNF).

## Getting Started

1. Define your CFG in the Dart code, similar to the provided input example.

2. Execute the `main` function to start processing your CFG.

3. The program will print the results of each step, including the simplified CFG and the CNF version.

## Use Cases

- **Language Recognition**: Simplify CFGs for use in parsers and compilers.

- **Automata Theory**: Analyze formal languages using clean and well-defined CFGs.

- **Academic Learning**: Understand and visualize the transformation of CFGs to CNF.

- **Natural Language Processing**: Preprocess CFGs for syntactic analysis.

## Contribution

Feel free to contribute to this project by opening issues, suggesting improvements, or submitting pull requests. Your contributions are welcome and encouraged.

## License

This project is open source and available under the MIT License. You are free to use, modify, and distribute it as needed. Please refer to the `LICENSE` file for more details.
