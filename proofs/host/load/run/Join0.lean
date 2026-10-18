import host.load.run.S0.States
import host.load.run.S1.States
namespace Host.Load.Run
set_option maxRecDepth 1000000 in
seg_join S0.P S1.P
end Host.Load.Run
