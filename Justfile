## Justfile - for build orchestration
##     Copyright (C) 2024-2025  Kıvılcım Defne Öztürk
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.
set unstable

# for compiling Lua
lua := require("luajit") || require("./lua")
luac := require("luac")
luarocks := require("./luarocks")
luacheck := require("luacheck")

# for testing environment
podman := require("podman")
busted := require("busted")

# for documentation
lualatex := which("lualatex")

# to hook up lament itself
lament := "src/cli/lament"

default:
    just -l

[group("util")]
[doc('Sets up required programs for the environment')]
setup-env:
    true

[group("test"), group("lint")]
[doc("Lints the rockspec.")]
lint-rockspec:
    {{luarocks}} lint lament-*.rockspec
    @echo "{{UNDERLINE + GREEN + BOLD}}Successfully linted rockspec.{{NORMAL}}"
[group("test"), group("lint"), doc("Lints the source code for the project.")]
lint-source:
    {{luacheck}} src/*
    @echo "{{UNDERLINE + GREEN + BOLD}}Successfully linted source code.{{NORMAL}}"
[group("test"), group("lint"), doc("Lints tests under spec/")]
lint-tests:
    {{luacheck}} spec/*
    @echo "{{UNDERLINE + GREEN + BOLD}}Successfully linted tests.{{NORMAL}}"
[group("test"), group("lint"), doc("Lints the project.")]
lint: lint-rockspec lint-source lint-tests
    @echo "{{UNDERLINE + GREEN + BOLD}}Linting done.{{NORMAL}}"
[group("test"), doc("Checks the testing framework for bugs.")]
check-busted FORMAT="utfTerminal": lint
    {{busted}} -v -o {{FORMAT}} spec/check_busted_spec.lua
    @echo "{{UNDERLINE + GREEN + BOLD}}busted passed the bug check test."
[group("test"), doc("Runs tests")]
test FORMAT="utfTerminal": check-busted
    {{busted}} -v -o {{FORMAT}}

[group("build")]
[doc("Compiles the project documentation.")]
doc-build:
    mkdir -p docs/out
    {{lualatex}} --halt-on-error --interaction=nonstopmode --output-directory=docs/out docs/README.tex
[group("build"), doc("Builds the project.")]
build: setup-env test
    {{luarocks}} build
[group("build"), doc("Cleans the artifacts generated by build tasks.")]
clean:
    {{luarocks}} remove --force lament || true
    rm -f *.rock *.rockspec~
    rm -f docs/out/* docs/chapters/*.aux docs/chapters/*.log docs/chapters/*.toc docs/chapters/*.dvi
    rm -f docs/*.aux docs/*.log docs/*.toc docs/*.dvi docs/*.fdb_latexmk docs/*.fls

[group("exec")]
[doc("Executes the project")]
run *args:
    {{lament}} {{args}}
