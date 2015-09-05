# L10N verifier script

## Usage

1. Download the raw script (no need to clone the repository)
2. In terminal, locate the L10NVerifier.swift file you just downloaded
3. Type `chmod a+x L10NVerifier.swift`
4. Run the script by typing `./L10NVerifier.swift {L10N.swift path} {Localizable.strings path}`

## Known limitations

* Code is really, really dirty and deserves a refactoring.
* Accepts only a single `L10N.swift` file and single `Localizable.strings` file at a time.
* Shows no progress while running.