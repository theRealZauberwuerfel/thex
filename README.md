# THex

THex should be a cool terminal version of Hex, a popular board game which roots
in the 1940s.

## Building

Well, it's a cabal project, but for now let's build it another way.
I assume you have the Nix package manager installed (or get it now).

We now need an environment for having all ncurses dependencies.
You do `nix-shell ./ncurses-shell.nix`
then `cabal install ncurses`
then `chmod +x build.sh`
then `sh build.sh`
this compiles the `Main.hs` in the `src/` directory.

## Having fun
If you know want to play enter `./thex` and let the adventure begin.
