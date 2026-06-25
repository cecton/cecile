--[[
-- default sink override (disabled)
--
local done = false

SimpleEventHook {
  name = "set-default-sink/force-configured",
  after = { "default-nodes/find-best-default-node",
            "default-nodes/find-selected-default-node",
            "default-nodes/find-stored-default-node" },
  before = { "default-nodes/apply-default-node" },
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-default-node" },
      Constraint { "default-node.type", "=", "audio.sink" },
    },
  },
  execute = function (event)
    if done then return end
    done = true

    local source = event:get_source ()
    local om = source:call ("get-object-manager", "metadata")
    local metadata = om:lookup { Constraint { "metadata.name", "=", "default" } }

    metadata:set (0, "default.configured.audio.sink", "Spa:String:JSON",
                  Json.Object { ["name"] = target_sink }:to_string ())
    log:warning ("configured default sink to " .. target_sink)
  end
}:register ()
--]]

local args = ...
local config = args:parse(4)

local route_rules = config.route or {}

if #route_rules == 0 then
  return
end

log = Log.open_topic ("s-set-default-sink")
local lutils = require ("linking-utils")

SimpleEventHook {
  name = "routing/force-apps-to-hdmi",
  after = { "linking/find-default-target" },
  before = { "linking/prepare-link" },
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-target" },
    },
  },
  execute = function (event)
    local source, om, si, si_props, si_flags, target =
        lutils:unwrap_select_target_event (event)
    if not target then return end

    for _, rule in ipairs (route_rules) do
      local match = true
      for key, value in pairs (rule.match) do
        if si_props [key] ~= value then
          match = false
          break
        end
      end
      if match then
        local found = nil
        for lnkbl in om:iterate { type = "SiLinkable" } do
          local p = lnkbl.properties
          local match_target = true
          for key, value in pairs (rule.target) do
            if p [key] ~= value then
              match_target = false
              break
            end
          end
          if match_target then
            found = lnkbl
            break
          end
        end
        if found then
          event:set_data ("target", found)
          local name = si_props ["node.name"] or si_props ["application.name"]
          log:warning ("routed " .. name)
        end
        return
      end
    end
  end
}:register ()
