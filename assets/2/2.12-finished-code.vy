# @version >=0.2.4 <0.3.0

struct Pokemon:
    name: String[32]
    dna: uint256
    HP: uint256
    matches: uint256
    wins: uint256
    
struct Trainer:
    name: String[32]

DNA_DIGITS: constant(uint256) = 16
DNA_MODULUS: constant(uint256) = 10 ** DNA_DIGITS
HP_LIMIT: constant(uint256) = 1000 
WILD_POKEMON: constant(address) = 0xB8c77482e45F1F44dE1745F52C74426C631bDD52

trainerList: HashMap[address, Trainer]
pokemonList: HashMap[uint256, Pokemon]
trainerToPokemon: HashMap[address, HashMap[uint256, Pokemon]]

ownerPokemonCount: HashMap[address, uint256]
totalPokemonCount: public(uint256)

event NewPokemon:
    name: String[32]
    dna: uint256
    HP: uint256

event NewTrainer:
    name: String[32]


interface WildPokemons:
    def battle(pokemon: Pokemon) -> (bool, String[32], uint256, uint256): nonpayable

@external
def battleWildPokemon(pokemonIndex: uint256):

    assert pokemonIndex < self.ownerPokemonCount[msg.sender], "Invalid Index Provided"

    battleResult: bool = empty(bool)
    newPokemonName: String[32] = empty(String[32])
    newPokemonDNA: uint256 = empty(uint256)
    newPokemonHP: uint256 = empty(uint256)

    battleResult, newPokemonName, newPokemonDNA, newPokemonHP = WildPokemons(WILD_POKEMON).battle(self.trainerToPokemon[msg.sender][pokemonIndex])

    if(battleResult):

        self.trainerToPokemon[msg.sender][pokemonIndex].matches +=1
        self.trainerToPokemon[msg.sender][pokemonIndex].wins +=1

        newPokemon: Pokemon = Pokemon({
            name: newPokemonName,
            dna: newPokemonDNA,
            HP: newPokemonHP,
            matches: 1,
            wins: 0
        })
    
        self.pokemonList[self.totalPokemonCount] = newPokemon
        self.totalPokemonCount += 1

        self.trainerToPokemon[msg.sender][self.ownerPokemonCount[msg.sender]] = newPokemon
        self.ownerPokemonCount[msg.sender] += 1

        log NewPokemon(newPokemonName, newPokemonDNA, newPokemonHP)

    else:
        self.trainerToPokemon[msg.sender][pokemonIndex].matches +=1

@pure
@internal
def _generateRandomDNA(name: String[32]) -> uint256:
    random: uint256 = convert(keccak256(name), uint256)
    return random % DNA_MODULUS

@internal
def _createPokemon(name: String[32]) -> Pokemon:
    randomDNA: uint256 = self._generateRandomDNA(name)

    randomHP: uint256 = randomDNA % HP_LIMIT

    newPokemon: Pokemon = Pokemon({
        name: name,
        dna: randomDNA,
        HP: randomHP,
        matches: 0,
        wins: 0
    })
    
    self.pokemonList[self.totalPokemonCount] = newPokemon
    self.totalPokemonCount += 1

    log NewPokemon(name, randomDNA, randomHP)

    return newPokemon


@external
def createTrainer(trainerName: String[32], pokemonName: String[32]):
    
    # create a pokemon
    newPokemon: Pokemon = self._createPokemon(pokemonName)

    newTrainer: Trainer = Trainer({
        name: trainerName
    })

    self.trainerList[msg.sender] = newTrainer
    self.trainerToPokemon[msg.sender][self.ownerPokemonCount[msg.sender]] = newPokemon
    self.ownerPokemonCount[msg.sender] += 1

    log NewTrainer(trainerName)

@view
@external
def listTrainerPokemon(pokemonIndex: uint256) -> Pokemon:
    assert pokemonIndex < self.ownerPokemonCount[msg.sender], "Invalid Index Provided"
    return self.trainerToPokemon[msg.sender][pokemonIndex]