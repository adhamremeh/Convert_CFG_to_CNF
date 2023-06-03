Map<String, List<String>> cfg = {};
List<String> nullableHeads = [];
bool canRemoveMoreNullables = false;
String input = '''
    S -> aS | SS | bA
    A -> BB
    B -> ab | aAbC | aAb | CC
    C -> ε
  ''';

void main() {
  Map<String, List<String>> cfg = cutGrammar(input);

  print("\n==============================\n");

  print(cfg);

  cfg = addStart(cfg);
  removeRedundunts(cfg);
  removeNullables(cfg);
  removeRedundunts(cfg);
  removeUnitProduction(cfg);
  removeNonGeneratingProductions(cfg);
  removeNonReachableProductions(cfg);

  print("\n==============================\n");

  print(cfg);

  print("\n==============================\n");

  List<String> ChomskyList = putInChomskyForm(cfg);
  printNewChomsky(ChomskyList);

  print("\n==============================\n");
}

/////////////////// add start state
Map<String, List<String>> addStart(Map<String, List<String>> cfg) {
  Map<String, List<String>> temp = cfg;
  cfg = {
    "S0": ["S"]
  };
  cfg.addAll(temp);

  return cfg;
}

void removeNonGeneratingProductions(Map<String, List<String>> cfg) {
  while (true) {
    try {
      for (String head in cfg.keys) {
        for (String part in cfg[head]!) {
          for (int i = 0; i < part.length; i++) {
            if (part[i] == part[i].toUpperCase() && cfg[part[i]] == null) {
              cfg[head]!.remove(part);
              break;
            }
          }
        }
      }
      break;
    } catch (_) {}
  }
}

void removeNonReachableProductions(Map<String, List<String>> cfg) {
  Map<String, bool> allVaraibles = {};
  cfg.keys.toList().forEach((element) {
    allVaraibles[element] = false;
  });
  allVaraibles.remove('S0');
  for (final variable in allVaraibles.keys)
    for (String head in cfg.keys) {
      for (String part in cfg[head]!) {
        if (part.contains(variable) && head != variable) {
          allVaraibles[variable] = true;
          break;
        }
      }
    }

  for (final variable in allVaraibles.keys) {
    if (!allVaraibles[variable]!) {
      cfg.remove(variable);
    }
  }
}

///////////////// removing nullables ////////////////////////
void removeNullables(Map<String, List<String>> cfg) {
  checkForNullables(cfg, nullableHeads);
  //remove at same level
  do {
    for (String head in nullableHeads) {
      removeNullableAtSingleLevel(cfg, head);
      //remove in other levels
      for (String otherHead in cfg.keys) {
        //remove single instances of original nullable

        if (cfg[otherHead]!.contains(head)) {
          removeNullableAtSingleLevel(cfg, otherHead, keepEpsillon: true);
        }

        List<String> bodyParts = cfg[otherHead]!;
        List<String> partsToAdd = [];
        for (final part in cfg[otherHead]!) {
          if (part.contains(head)) {
            List<int> headIndicies = [];
            //mark all occurunces of this head in the part
            for (int i = 0; i < part.length; i++) {
              if (part[i] == head) headIndicies.add(i);
            }
            //add all combinations except removing all
            for (final index in headIndicies) {
              partsToAdd.add(part.replaceRange(index, index + 1, ''));
            }
            //add combination where all nullables are removed
            partsToAdd.add(part.replaceAll(head, ''));
          }
        }
        partsToAdd = partsToAdd.map((element) {
          if (element == '' || element == ' ') {
            return 'ε';
          } else
            return element;
        }).toList();
        //remove duplicates
        cfg[otherHead] = (bodyParts + partsToAdd).toSet().toList();
      }
    }
    nullableHeads = [];
    canRemoveMoreNullables = checkForNullables(cfg, nullableHeads);
  } while (canRemoveMoreNullables);
}

void removeNullableAtSingleLevel(Map<String, List<String>> cfg, String head,
    {bool keepEpsillon = false}) {
  List<String> bodyParts = cfg[head]!;
  bodyParts.remove('ε');
  List<String> partsToAdd = [];
  for (String part in bodyParts) {
    if (part.contains(head)) {
      partsToAdd.add(part.replaceAll(head, ''));
    }
  }
  if (bodyParts.isEmpty) {
    cfg.remove(head);
    for (String h in cfg.keys) {
      List<String> newParts = [];
      for (String p in cfg[h]!) {
        newParts.add(p.replaceAll(head, ''));
      }
      newParts = newParts.map((element) {
        if (element == '' || element == ' ') {
          return 'ε';
        } else
          return element;
      }).toList();
      cfg[h] = newParts;
    }
    return;
  }

  cfg[head] = bodyParts + partsToAdd;
}

bool checkForNullables(
    Map<String, List<String>> cfg, List<String> nullableHeads) {
  for (String head in cfg.keys) {
    for (String part in cfg[head]!) {
      if (part.trim().contains('ε') && head != 'S0') {
        nullableHeads.add(head);
        return true;
      }
    }
  }
  return false;
}

////////////////////// remvoing unit productions
// This function check for location of unit production and remake the values without it
// .... uses checkForUnits to make sure there is no left unit productions
void removeUnitProduction(Map<String, List<String>> cfg) {
  while (checkForUnits(cfg)) {
    for (String head in cfg.keys) {
      for (String part in cfg[head]!) {
        if (part.length == 1 && part == part.toUpperCase()) {
          cfg[head]!.remove(part);
          if (cfg.containsKey(part)) {
            cfg[head] = (cfg[head]! + cfg[part]!);
          }
          break;
        }
      }
    }
  }
}

// A funtion that check if there is a unit production or not
bool checkForUnits(Map<String, List<String>> cfg) {
  for (String head in cfg.keys) {
    for (String part in cfg[head]!) {
      if (part.length == 1 && part == part.toUpperCase()) return true;
    }
  }
  return false;
}

// This function passes the head values and head for remakeHeadValues
// note: this is the function to call to remove redundunts not remakeHeadValues
void removeRedundunts(Map<String, List<String>> cfg) {
  for (String head in cfg.keys) {
    cfg[head] = remakeHeadValues(cfg[head]!, head);
  }
}

// A function that takes the cfg's head values and
//return it without duplicate values or same head terminal
List<String> remakeHeadValues(List<String> headVals, String head) {
  List<String> temp = [];

  headVals.forEach((element) {
    if (!temp.contains(element) && element != head) temp.add(element);
  });

  return temp;
}

////////////////////////////////chomsky form
List<String> putInChomskyForm(Map<String, List<String>> cfg) {
  List<String> newCFG = [];
  Map<String, String> newRulesReversed = {};
  List<String> newVariablePool = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];
  newVariablePool.removeWhere((element) => cfg.keys.contains(element));
  for (String head in cfg.keys) {
    for (String part in cfg[head]!) {
      if (part.length == 1) {
        if (part == 'ε') {
          newCFG.add('$head -> $part');
        } else if (part == part.toLowerCase()) {
          newCFG.add('$head -> $part');
        }
      } else if (part.length == 2) {
        if (part == part.toUpperCase()) {
          newCFG.add('$head -> $part');
        } else {
          String newPart = '';
          part.runes.forEach((int rune) {
            var character = String.fromCharCode(rune);
            if (character == character.toLowerCase()) {
              if (newRulesReversed.keys.contains(character)) {
                newPart += newRulesReversed[character]!;
              } else {
                newRulesReversed[character] = newVariablePool[0];
                newPart += '${newVariablePool[0]}';
                newVariablePool.removeAt(0);
              }
            } else {
              newPart += character; //uppercase
            }
          });
          newCFG.add('$head -> $newPart');
        }
      }
    }
  }
  for (String head in cfg.keys) {
    for (String part in cfg[head]!) {
      if (part.length >= 3) {
        String newPart = part;
        bool loopAgain = true;
        while (loopAgain) {
          int loopCounter = (newPart.length / 2).ceil();
          for (int i = 0; i < loopCounter; i++) {
            String tempNewPart = '';
            if (newPart.length == 2) break;
            String tempPart = newPart.substring(i, i + 2);
            if (newRulesReversed.containsKey(tempPart)) {
              tempNewPart = newRulesReversed[tempPart]!;
            } else {
              String tempDoublePart = '';
              tempPart.runes.forEach((int rune) {
                var character = String.fromCharCode(rune);
                if (character == character.toLowerCase()) {
                  if (newRulesReversed.keys.contains(character)) {
                    tempDoublePart += newRulesReversed[character]!;
                  } else {
                    newRulesReversed['${character}'] = newVariablePool[0];
                    tempDoublePart += '${newVariablePool[0]}';
                    newVariablePool.removeAt(0);
                  }
                } else {
                  tempDoublePart += character;
                }
              });
              if (newRulesReversed.keys.contains(tempDoublePart)) {
                tempNewPart = newRulesReversed[tempDoublePart]!;
              } else {
                newRulesReversed['${tempDoublePart}'] = newVariablePool[0];
                tempNewPart = '${newVariablePool[0]}';
                newVariablePool.removeAt(0);
              }
            }
            newPart = newPart.replaceAll(tempPart, tempNewPart);
          }
          if (newPart.length == 2) {
            if (newPart == newPart.toUpperCase()) {
              newCFG.add('$head -> $newPart');
            } else {
              String newPartTemp = '';
              newPart.runes.forEach((int rune) {
                var character = String.fromCharCode(rune);
                if (character == character.toLowerCase()) {
                  if (newRulesReversed.keys.contains(character)) {
                    newPartTemp += newRulesReversed[character]!;
                  } else {
                    newRulesReversed[character] = newVariablePool[0];
                    newPartTemp += '${newVariablePool[0]}';
                    newVariablePool.removeAt(0);
                  }
                } else {
                  newPartTemp += character; //uppercase
                }
              });
              newCFG.add('$head -> $newPartTemp');
            }
            loopAgain = false;
          }
        }
      }
    }
  }
  for (final item in newRulesReversed.keys) {
    newCFG.add('${newRulesReversed[item]} -> $item');
  }
  return newCFG;
}

void printNewChomsky(List<String> cnf) {
  Map<String, List<String>> temp = {};

  for (String line in cnf) {
    List<String> parts = line.split('->');
    if (temp[parts[0]] == null) {
      temp[parts[0]] = [];
    }
    temp[parts[0]]!.add(parts[1]);
  }

  String p = "";

  for (String key in temp.keys) {
    for (String part in temp[key]!) {
      p += part + " |";
    }
    print(key + "->" + p.substring(0, p.length - 1));
    p = "";
  }
}

/////////////////////////////////////////////////////
//bisects cfg into individual rules
Map<String, List<String>> cutGrammar(String grammar) {
  Map<String, List<String>> cnfGrammar = {};
  List<String> lines = grammar.split('\n');

  for (String line in lines) {
    if (line.trim() == '') {
      continue;
    }

    List<String> parts = line.split('->');
    String head = parts[0].trim();
    String body = parts[1].trim();

    List<String> bodyproductionRules = body.split('|');
    cnfGrammar[head] = [];

    for (String rule in bodyproductionRules) {
      cnfGrammar[head]!.add(rule.trim());
    }
  }

  return cnfGrammar;
}

void printCFG(Map<String, List<String>> cnfGrammar) {
  for (final key in cnfGrammar.keys) {
    for (final rule in cnfGrammar[key]!) {
      print('$key -> $rule');
    }
  }
}
