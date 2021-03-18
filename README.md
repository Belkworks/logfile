
# Logfile
*A simple logger, inspired by [missionlog](https://www.npmjs.com/package/missionlog).*

**Importing with [Neon](https://github.com/Belkworks/NEON)**:
```lua
log = NEON:github('belkworks', 'logfile')
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
