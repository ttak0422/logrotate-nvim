-- [nfnl] Compiled from fnl/logrotate/init.fnl by https://github.com/Olical/nfnl, do not edit.
local default_config = {targets = {}, config_path = (vim.fn.stdpath("data") .. "/logrotate"), interval = "weekly"}
local encode = vim.fn.json_encode
local decode = vim.fn.json_decode
local group = vim.api.nvim_create_augroup("logrotate", {clear = true})
local function dir_3f(path)
  local tmp_3_auto = vim.uv.fs_stat(path)
  if (nil ~= tmp_3_auto) then
    local tmp_3_auto0 = tmp_3_auto[type]
    if (nil ~= tmp_3_auto0) then
      return (tmp_3_auto0 == "directory")
    else
      return nil
    end
  else
    return nil
  end
end
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
    error(("Unknown interval: " .. interval))
    return false
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
  local _4_, _5_ = io.open(path, "r")
  if ((_4_ == nil) and true) then
    local _ = _5_
    return {}
  elseif (nil ~= _4_) then
    local fp = _4_
    return decode(fp:read("*a"))
  else
    return nil
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
  local timestamps_path = (vim.fn.expand(opt0.config_path) .. "/timestamps.json")
  local callback
  local function _7_()
    local timestamps = load_timestamps(timestamps_path)
    local function _8_(target)
      local target0 = vim.fn.expand(target)
      local now = os.time()
      local timestamp
      local _10_
      do
        local t_9_ = timestamps
        if (nil ~= t_9_) then
          t_9_ = t_9_[target0]
        else
        end
        _10_ = t_9_
      end
      timestamp = (_10_ or now)
      if rotate_3f(opt0.interval, timestamp, now) then
        rotate(target0)
        timestamps[target0] = now
        return nil
      else
        return nil
      end
    end
    vim.iter(opt0.targets):each(_8_)
    return save_timestamps(timestamps_path, timestamps)
  end
  callback = _7_
  do
    local path = vim.fn.expand(opt0.config_path)
    if not dir_3f(path) then
      vim.uv.fs_mkdir(path, 493)
    else
    end
  end
  return vim.api.nvim_create_autocmd({"VimLeave"}, {group = group, callback = callback})
end
return {setup = setup}
