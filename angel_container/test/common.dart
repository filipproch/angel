import 'package:angel_container/angel_container.dart';
import 'package:test/test.dart';

void returnVoidFromAFunction(int x) {}

void testReflector(Reflector reflector) {
  var blaziken = new Pokemon('Blaziken', PokemonType.fire);
  Container container;

  setUp(() {
    container = new Container(reflector);
    container.registerSingleton(blaziken);
  });

  test('get field', () {
    var blazikenMirror = reflector.reflectInstance(blaziken);
    expect(blazikenMirror.getField<PokemonType>('type'), blaziken.type);
  });

  group('reflectFunction', () {
    var mirror = reflector.reflectFunction(returnVoidFromAFunction);

    test('void return type returns dynamic', () {
      expect(mirror.returnType, reflector.reflectType(dynamic));
    });

    test('counts parameters', () {
      expect(mirror.parameters, hasLength(1));
    });

    test('counts types parameters', () {
      expect(mirror.typeParameters, isEmpty);
    });

    test('correctly reflects parameter types', () {
      var p = mirror.parameters[0];
      expect(p.name, 'x');
      expect(p.isRequired, true);
      expect(p.isNamed, false);
      expect(p.annotations, isEmpty);
      expect(p.type, reflector.reflectType(int));
    });
  });

  test('make on singleton type returns singleton', () {
    expect(container.make(Pokemon), blaziken);
  });

  test('make with generic returns same as make with explicit type', () {
    expect(container.make<Pokemon>(), blaziken);
  });

  test('make on aliased singleton returns singleton', () {
    container.registerSingleton(blaziken, as: StateError);
    expect(container.make(StateError), blaziken);
  });

  test('constructor injects singleton', () {
    var lower = container.make<LowerPokemon>();
    expect(lower.lowercaseName, blaziken.name.toLowerCase());
  });

  test('newInstance works', () {
    var type = container.reflector.reflectType(Pokemon);
    var instance =
        type.newInstance('changeName', [blaziken, 'Charizard']) as Pokemon;
    print(instance);
    expect(instance.name, 'Charizard');
    expect(instance.type, PokemonType.fire);
  });
}

class LowerPokemon {
  final Pokemon pokemon;

  LowerPokemon(this.pokemon);

  String get lowercaseName => pokemon.name.toLowerCase();
}

class Pokemon {
  final String name;
  final PokemonType type;

  Pokemon(this.name, this.type);

  factory Pokemon.changeName(Pokemon other, String name) {
    return new Pokemon(name, other.type);
  }

  @override
  String toString() => 'NAME: $name, TYPE: $type';
}

enum PokemonType { water, fire, grass, ice, poison, flying }
