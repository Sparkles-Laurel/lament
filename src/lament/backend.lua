-- backend.lua - defines backend API functions
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
local pl = require('pl')
local lament_hive = require('lament.hive')
local lpeg = require('lpeg')
local lfs = require('lfs')

-- Base class from which the backends derive
lament.backend.Backend = pl.class()

--- creates a new LAMENT backend
--- @param name string The name for the backends
function lament.backend.Backend:_init(name)
   --- The name for the backend
   self.name = name
   --- Whether the backend is active or not
   self.active = false
   --- The hives registered by the backend
   self.hives = {}
   --- The files demanded by the backend
   self.files = {}
   --- The capabilities of the backend
   -- TODO: add permissions to backends, like accessing
   -- systemd commands or just editing files
   self.capabilities = {}
end

--- Initializes the backend
--- The function merely calls the `on_init` function of the backend
--- and sets `active` to `true`
function lament.backend.Backend:init()
   if self:on_init(self.hives, self.files) then
      self.active = true
      for i = 1, #self.hives, 1 do
         lament._sysconf[self.hives[i].name] = self.hives[i]
      end
   end
   return self
end

--- Shuts the backend down
---@return table
function lament.backend.Backend:exit()
   if self:on_exit(self.hives, self.files) then
      self.active = false
   end
   return self
end

--- Forwards-applies the configuration as specified by the backend
function lament.backend.Backend:apply()
   return true
end

--- Backwards-applies the configuration as specified by the backend
function lament.backend.Backend:recalibrate()
   return true
end

--- Determines whether the backend is the configuration backend for LAMENT itself
function lament.backend.Backend:is_auto()
   -- LAMENT's auto-configuration backend is named `lament._sysconf.lament`
   -- The only hive created by the auto-config is called `lament.lament`
   -- and this hive is unique to LAMENT - no other hive is allowed to create an auto-configuration
   -- This table declares a list of keys that will be more clearly determined
   -- in the future.

   -- TODO: apply more sanitized checks
   return self.name == "lament"
end
