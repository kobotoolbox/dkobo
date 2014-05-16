# @log function for debugging
@log = @dump = (args...)-> console?.log?.apply console, args
