local log = require "log"

log.warn("this non-standard location, `socket.ltn12`, has been depricated, please require as the standard top-level module `ltn12`")

return require "ltn12"
