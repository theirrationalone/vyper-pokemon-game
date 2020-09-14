# @version >=0.2.4 <0.3.0

DNA_DIGITS: constant(uint256) = 16
DNA_MODULUS: constant(uint256) = 10 ** DNA_DIGITS

struct Pokemon:
    name: String[32]
    dna: uint256
    HP: uint256
    matches: uint256
    wins: uint256

totalPokemonCount: public(uint256)
pokemonList: HashMap[uint256, Pokemon]

@pure
@internal
def _generateRandomDNA(_name: String[32]) -> uint256:
    random: uint256 = convert(keccak256(_name), uint256)
    return random % DNA_MODULUS

@internal
def _createPokemon(_name: String[32], _dna: uint256, _HP: uint256):
    self.pokemonList[self.totalPokemonCount] = Pokemon({
        name: _name,
        dna: _dna,
        HP: _HP,
        matches: 0,
        wins: 0
    })
