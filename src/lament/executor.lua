-- executor.lua - responsible for execution of the tasks
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

local lament = require("lament")
local pl = require("pl")

require("lament.util.enum")
require("lament.loader")
require("lament.hooks")

local switch, case = assert(require("lament.util.switch"))

lament.executor = {}

lament.executor.CeaseAnd = assert(lament.enum(
   'halt',
   'load_last',
   'infer_from_effective',
   'infer_from_desired'
), "BUG: lament.enum returns falsy values")

--- Starts calibration of the system according to the desired state
--- If the desired state is malconfigured, perform the appropriate resolution,
--- as defined by the key `cease_and` in the auto-config.
function lament.executor.start_application()
   -- Obtain cessation behavior
   local cease_and = lament._sysconf.lament.cease_and or lament.executor.CeaseAnd.load_last
   -- Prepare backends
   lament.boot_backends()
   -- Apply forwards.
   for i = 1, #lament.backends do
      if not lament.backends[i].apply() then
         switch(cease_and) {
            [case(lament.executor.CeaseAnd.halt())] = function ()
               error(string.format("Backend %s failed to recalibrate", lament.backends[i].name), 2)
            end,
            [case(lament.executor.CeaseAnd.infer_from_effective())] = function ()
               lament.hooks.infer_etc_hook()
            end,
            [case(lament.executor.CeaseAnd.infer_from_desired())] = function ()
               lament.hooks.infer_decl_hook()
            end,
            [case(lament.executor.CeaseAnd.load_last())] = function ()
               lament.hooks.load_last_hook()
            end
         }
         goto continue
      end
      ::continue::
   end
end

--- Starts recalibration of the system state according to the present state
--- If the present state is malconfigured, performs the desired resolution
--- as defined by the key `cease_and` in the auto-config.
function lament.executor.start_recalibration()
   -- Obtain cessation behavior
   local cease_and = lament._sysconf.lament.cease_and or lament.executor.CeaseAnd.load_last
   -- Prepare backends
   lament.boot_backends()
   -- Apply backwards (commit recalibration)
   for i = 1, #lament.backends do
      if not lament.backends[i].recalibrate() then
         switch(cease_and) {
            [case(lament.executor.CeaseAnd.halt())] = function ()
               error(string.format("Backend %s failed to recalibrate", lament.backends[i].name), 2)
            end,
            [case(lament.executor.CeaseAnd.infer_from_effective())] = function ()
               lament.hooks.infer_etc_hook()
            end,
            [case(lament.executor.CeaseAnd.infer_from_desired())] = function ()
               lament.hooks.infer_decl_hook()
            end,
            [case(lament.executor.CeaseAnd.load_last())] = function ()
               lament.hooks.load_last_hook()
            end
         }
      end
   end
end

lament.executor.__cessation_actions = {}

return lament.executor
