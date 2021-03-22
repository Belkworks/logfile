-- logfile.moon
-- SFZILabs 2021

merge = (dest, source) -> dest[k] = v for k, v in pairs source

LogLevel =
	INFO: "INFO"
	WARN: "WARN"
	ERROR: "ERROR"
	OFF: "OFF"

LogPriority =
	OFF: -1
	INFO: 0
	WARN: 1
	ERROR: 2

Logger = {
	tags: {}
	logfn: nil
}

merge Logger,
	init: (config, callback) ->
		if callback
			assert 'function' == type(callback),
				'logger: arg2 must be a function!'

			Logger.logfn = callback
		
		if config
			for k, v in pairs config
				assert LogLevel[v], 'invalid log level for: '..k
				Logger.tags[k] = name: k, level: v or 'INFO'

		unless config or callback
			Logger.logfn = nil

	resolveTag: (tag) ->
		if 'string' == type tag
			if t = Logger.tags[tag]
				return Logger.resolveTag t

		elseif 'table' == type tag
			if tag.name
				return tag.name, LogPriority[tag.level]
		
		error 'couldnt resolve tag: '..tag

	shouldLog: (tag, level) ->
		return unless Logger.logfn
		name, tagLevel = Logger.resolveTag tag
		return if tagLevel == LogPriority.OFF
		return name if tagLevel <= level

	error: (tag, ...) ->
		if name = Logger.shouldLog tag, LogPriority.ERROR
			Logger.logfn LogLevel.ERROR, name, ...

	warn: (tag, ...) ->
		if name = Logger.shouldLog tag, LogPriority.WARN
			Logger.logfn LogLevel.WARN, name, ...

	info: (tag, ...) ->
		if name = Logger.shouldLog tag, LogPriority.INFO
			Logger.logfn LogLevel.INFO, name, ...

keys = (T) -> [i for i in pairs T]
isArray = (T) -> #T == #keys T

stringify = (V, wrap) ->
	switch type V
		when 'number', 'boolean', 'function'
			tostring V
		when 'string'
			if wrap
				'%q'\format V
			else V
		when 'table'
			return '[]' if #keys(V) == 0
			if isArray V
				values = table.concat [stringify v for v in *V], ', '
				'['..values..']'
			else -- TODO: pretty print
				values = for k, v in pairs V
					k = stringify k, true
					v = stringify v, true
					k .. ': ' .. v
				'{' .. table.concat(values, ', ') ..'}'

		when 'nil'
			'NIL'
		
		-- TODO: userdata

Logger.logfile = (path) ->
	writeline = (text) ->
		text ..= '\n'
		if isfile path
			appendfile path, text
		else writefile path, text

	(level, tag, ...) -> -- TODO: new thread?
		args = {...}
		formatted = [stringify args[i] for i = 1, table.maxn args]
		writeline "%s  %s\t[%s] %s"\format os.date!, level, tag, table.concat formatted, ' '

Logger.combine = (...) ->
	fns = {...}
	(...) ->
		for fn in *fns
			fn ...

Logger
