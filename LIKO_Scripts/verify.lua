local common = require("docscripts")

local verbose, path = common.parseargs({...})

local data, errors = common.loadDirectory(path)

local plugins = {}

function plugins.syntax(data, errors)
  if #errors > 0 then
    return false, errors
  else
    return true
  end
end

function plugins.methods(data, _errors)
  local flag = true
  local errors = {}
  for pname, peripheral in pairs(data) do
    if peripheral.methods then
      for mname, method in pairs(peripheral.methods) do
        if (not method.availableSince) or (not method.lastUpdatedIn) or (not method.shortDescription) then
          flag = false
          table.insert(errors, "in peripheral "..pname.." in method "..mname)
        end
      end
    end
  end
  if flag then
    return true
  else
    return false, errors
  end
end

function plugins.isDocumented(data, _errors)
  flag = true
  local errors = {}
  local list = BIOS.HandledAPIS()
  for peripheral, methods in pairs(list) do
    if not data[peripheral] then
      flag = false
      table.insert(errors, "Peripheral " .. peripheral .. " is not documented.")
    else
      for method, _ in pairs(methods) do
        if not data[peripheral].methods[method] then
          flag = false
          table.insert(errors, "Method " .. method .. " in peripheral " .. peripheral .. " is not documented.")
        end
      end
    end
  end
  return flag, errors
end

color(12) common.log("Verifying JSON files") color(5)

for k, v in pairs(plugins) do
  common.log(k)
  local ok, errors = v(data, errors)
  if ok then
    color(12) common.log("PASSED") color(5)
  else
    for _,error in ipairs(errors) do
      common.log(error)
    end
    return 1, k .. " FAILED"
  end
end

color(12) common.log("Verified all JSONs successfully.")
