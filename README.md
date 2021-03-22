
# Logfile
*A simple logger, inspired by [missionlog](https://www.npmjs.com/package/missionlog).*

**Importing with [Neon](https://github.com/Belkworks/NEON)**:
```lua
log = NEON:github('belkworks', 'logfile')
```

See the bottom of this file for an annotated example.

## Definitions

**writer**: `(level, tag, ...) -> nil`  

A writer is a function responsible for logging information to an output.
A writer receives:
- a level (either 'ERROR', 'WARN', or 'INFO').  
- a tag (as a string)
- any number of arguments

**levels**: A dictionary of `tag -> level`, with both being strings.

## API

**logfile**: `log.logfile(path) -> writer`  
Returns a writer that writes to the file at `path`.  
If the file doesn't exist, it will be created when something is logged.
```lua
file = log.logfile('events.log')
```

**init**: `log.init(levels, writer) -> nil`  
Set the levels and writer of the log.  
If both arguments are `nil`, the loggers writer is unset.
```lua
levels = {system = 'WARN'}
file = log.logfile('abc.log')
log.init(levels, file)

-- same as above
log.init(levels)
log.init(nil, file)
```

**info**: `log.info(tag, ...) -> nil`  
Logs `...` if `tag`'s log level is `INFO`.

**warn**: `log.warn(tag, ...) -> nil`  
Logs `...` if `tag`'s log level is `WARN` or `ERROR`.

**error**: `log.warn(tag, ...) -> nil`  
Logs `...` if `tag`'s log level is not `OFF`.

**tags**: `log.tags -> table`  
The current dictionary of tags and their levels.

**combine**: `log.combine(writers...) -> writer`  
Returns a new writer that runs all of the given writers.
```lua
file1 = log.logfile('events.log')
file2 = log.logfile('events2.log')
both = log.combile(file1, file2) -- writer that runs file1 and file2
log.init(nil, both)
```

## Example

```lua
file = log.logfile('events.log')
levels = {
    system = "WARN",
    other = "INFO",
    hush = "OFF"
}

log.init(levels, file)

-- doesn't log - system's minimum level is WARN
log.info('system', 'did something')

-- logs a warning
log.warn('system', 'uh oh')

-- logs an error
log.error('system', 'something happened')

-- you can pass a tag instead of a string
tags = log.tags
log.warn(tags.system, 'uh oh!')

-- you can pass multiple arguments
log.info('other','hello','world')

-- won't log, its level is OFF
log.error('hush','oh no!')

-- you can change log levels on the fly
log.init({hush="INFO"})

-- logs an error now because we changed it
log.error('hush','this one logs!')

-- pass nothing to clear the callback (stop logging)
log.init()
```

## Advanced Usage
Instead of using `logfile`, you can use a custom writer function.
```lua
levels = {
    system = "WARN",
    other = "INFO",
    hush = "OFF"
}

log.init(levels, function(level, tag, ...)
    -- level is 'ERROR', 'WARN', or 'INFO'
    -- tag is the name of the tag as a string
    -- ... is the passed parameters
    print(...)
end)

log.info('other', 'hello:', 'world')
-- writer called with ('INFO', 'other', 'hello:', 'world')
```
