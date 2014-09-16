# @log function for debugging
@log = (args...)-> console?.log?.apply console, args
if !@dump?
  @dump = @log