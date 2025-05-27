-- lament.lua - provides the global system configuration of LAMENT
--
--     Copyright (C) 2024-2025  Kıvılcım Defne Öztürk
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.


local lament = require('lament')
local conf = {}

conf.lament = {
   --- Global system state
   _sysconf = {
      --- Self-configuration of LAMENT
      ["lament"] = {
         --- Behaviour of LAMENT in case application fails
         cease_and = lament.executor.CeaseAnd.halt
      }
   }
}

-- The global configuration table is a special table. It needs to override the

require('lament.hive')
require('lament.key')
require('lament.loader')


return lament
