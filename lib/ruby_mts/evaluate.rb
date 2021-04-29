#.......................................................
# Do not move this 'evaluate'  function inside a module
# Otherwise, the eval_uated class will be prefixed
# with the module itself
# ......................................................
require_relative '../ruby_mts'
def evaluate simfile
  eval IO.read(simfile)
end
