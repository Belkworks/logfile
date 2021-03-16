local merge
merge = function(dest, source)
  for k, v in pairs(source) do
    dest[k] = v
  end
end
local LogLevel = {
  INFO = "INFO",
  WARN = "WARN",
  ERROR = "ERROR",
  OFF = "OFF"
}
local LogPriority = {
  OFF = -1,
  INFO = 0,
  WARN = 1,
  ERROR = 2
}
local Logger = {
  tags = { },
  logfn = nil
}
merge(Logger, {
  init = function(config, callback)
    if callback then
      assert('function' == type(callback), 'logger: arg2 must be a function!')
      Logger.logfn = callback
    end
    if config then
      for k, v in pairs(config) do
        assert(LogLevel[v], 'invalid log level for: ' .. k)
        Logger.tags[k] = {
          name = k,
          level = v or 'INFO'
        }
      end
    end
    if not (config or callback) then
      Logger.logfn = nil
    end
  end,
  resolveTag = function(tag)
    if 'string' == type(tag) then
      do
        local t = Logger.tags[tag]
        if t then
          return Logger.resolveTag(t)
        end
      end
    elseif 'table' == type(tag) then
      if tag.name then
        return tag.name, LogPriority[tag.level]
      end
    end
    return error('couldnt resolve tag: ' .. tag)
  end,
  shouldLog = function(tag, level)
    if not (Logger.logfn) then
      return 
    end
    local name, tagLevel = Logger.resolveTag(tag)
    if tagLevel == LogPriority.OFF then
      return 
    end
    if tagLevel <= level then
      return name
    end
  end,
  error = function(tag, ...)
    do
      local name = Logger.shouldLog(tag, LogPriority.ERROR)
      if name then
        return Logger.logfn(LogLevel.ERROR, name, ...)
      end
    end
  end,
  warn = function(tag, ...)
    do
      local name = Logger.shouldLog(tag, LogPriority.WARN)
      if name then
        return Logger.logfn(LogLevel.WARN, name, ...)
      end
    end
  end,
  info = function(tag, ...)
    do
      local name = Logger.shouldLog(tag, LogPriority.INFO)
      if name then
        return Logger.logfn(LogLevel.INFO, name, ...)
      end
    end
  end
})
local keys
keys = function(T)
  local _accum_0 = { }
  local _len_0 = 1
  for i in pairs(T) do
    _accum_0[_len_0] = i
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
local isArray
isArray = function(T)
  return #T == #keys(T)
end
local stringify
stringify = function(V, wrap)
  local _exp_0 = type(V)
  if 'number' == _exp_0 or 'boolean' == _exp_0 or 'function' == _exp_0 then
    return tostring(V)
  elseif 'string' == _exp_0 then
    if wrap then
      return ('%q'):format(V)
    else
      return V
    end
  elseif 'table' == _exp_0 then
    if #keys(V) == 0 then
      return '[]'
    end
    if isArray(V) then
      local values = table.concat((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #V do
          local v = V[_index_0]
          _accum_0[_len_0] = stringify(v)
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), ', ')
      return '[' .. values .. ']'
    else
      local values
      do
        local _accum_0 = { }
        local _len_0 = 1
        for k, v in pairs(V) do
          k = stringify(k, true)
          v = stringify(v, true)
          local _value_0 = k .. ': ' .. v
          _accum_0[_len_0] = _value_0
          _len_0 = _len_0 + 1
        end
        values = _accum_0
      end
      return '{' .. table.concat(values, ', ') .. '}'
    end
  elseif 'nil' == _exp_0 then
    return 'NIL'
  end
end
Logger.logfile = function(path)
  local writeline
  writeline = function(text)
    text = text .. '\n'
    if isfile(path) then
      return appendfile(path, text)
    else
      return writefile(path, text)
    end
  end
  return function(level, tag, ...)
    local args = {
      ...
    }
    local formatted
    do
      local _accum_0 = { }
      local _len_0 = 1
      for i = 1, table.maxn(args) do
        _accum_0[_len_0] = stringify(args[i])
        _len_0 = _len_0 + 1
      end
      formatted = _accum_0
    end
    return writeline(("%s  %s\t[%s] %s"):format(os.date(), level, tag, table.concat(formatted, ' ')))
  end
end
return Logger
