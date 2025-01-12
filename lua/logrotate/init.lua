-- [nfnl] Compiled from fnl/logrotate/init.fnl by https://github.com/Olical/nfnl, do not edit.
local default_config = {targets = {}, config_path = (vim.fn.stdpath("data") .. "/logrotate.json"), interval = "weekly"}
local encode = vim.fn.json_encode
local decode = vim.fn.json_decode
local group = vim.api.nvim_create_augroup("logrotate", {clear = true})
local function rotate_3f(interval, t1, t2)
  local diff = math.abs((t1 - t2))
  if (interval == "daily") then
    return (diff > 86400)
  elseif (interval == "weekly") then
    return (diff > 604800)
  elseif (interval == "monthly") then
    return (diff > 2592000)
  else
    local _ = interval
    return error(("Unknown interval: " .. interval))
  end
end
local function rotate(path)
  local name = vim.fn.fnamemodify(path, ":t:r")
  local ext = vim.fn.fnamemodify(path, ":e")
  local dir = vim.fn.fnamemodify(path, ":h")
  local timestamp = os.date("%Y%m%d")
  local new_path = (dir .. "/" .. name .. "_" .. timestamp .. "." .. ext)
  return os.rename(path, new_path)
end
local function load_timestamps(path)
  local _2_ = io.open(path, "r")
  if (nil ~= _2_) then
    local fp = _2_
    return decode(fp:read("*a"))
  else
    local _ = _2_
    return {}
  end
end
local function save_timestamps(path, timestamps)
  local tmp_9_auto = io.open(path, "w")
  tmp_9_auto:write(encode(timestamps))
  tmp_9_auto:close()
  return tmp_9_auto
end
local function setup(opt)
  local opt0 = vim.tbl_deep_extend("force", default_config, (opt or {}))
  local timestamps_path = vim.fn.expand(opt0.config_path)
  local callback
  local function _4_()
    local timestamps = load_timestamps(timestamps_path)
    local function _5_(target)
      local target0 = vim.fn.expand(target)
      local now = os.time()
      local timestamp
      local _7_
      do
        local t_6_ = timestamps
        if (nil ~= t_6_) then
          t_6_ = t_6_[target0]
        else
        end
        _7_ = t_6_
      end
      timestamp = (_7_ or now)
      if rotate_3f(opt0.interval, timestamp, now) then
        rotate(target0)
        timestamps[target0] = now
        return nil
      else
        timestamps[target0] = timestamp
        return nil
      end
    end
    vim.iter(opt0.targets):each(_5_)
    return save_timestamps(timestamps_path, timestamps)
  end
  callback = _4_
  return vim.api.nvim_create_autocmd({"VimLeave"}, {group = group, callback = callback})
end
return {setup = setup}
