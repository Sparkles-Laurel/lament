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
lua := require("luajit") || require("lua")
luac := require("luac")
luarocks := require("luarocks")
luacheck := require("luacheck")

# for testing environment
podman := require("podman")
busted := require("busted")

# for documentation
lualatex := which("lualatex")


[group("util")]
setup-env:
    {{luarocks}} install lanes

[group("test")]
lint:
    {{luarocks}} lint lament-*.rockspec
    {{luacheck}} src/*
test:
    {{busted}} -o TAP

[group("build")]
build: setup-env test
    {{luarocks}} build
doc-build:
    {{lualatex}} docs/README.tex
