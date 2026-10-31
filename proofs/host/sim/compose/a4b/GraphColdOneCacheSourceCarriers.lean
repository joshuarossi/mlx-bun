import host.sim.compose.a4b.GraphColdOneSource
import host.sim.compose.a4b.GraphColdCacheOpsIn
import host.simgraph.world.Caches
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.OneCache
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.FfiEval _root_.Host.Load.Layers

def cacheEnv : Env := [(chars!"cache", 2586)]
def wideDomain : List Nat := [2673484, 2673485, 4910]

def cacheObjects : List Nat := [2672300, 2672305, 2672310, 2672322, 2672331, 2672336, 2672341, 2672353, 2672362, 2672367, 2672372, 2672384, 2672393, 2672398, 2672403, 2672415, 2672424, 2672429, 2672434, 2672446, 2672455, 2672460, 2672465, 2672477, 2672486, 2672491, 2672496, 2672508, 2672517, 2672522, 2672527, 2672539, 2672548, 2672553, 2672558, 2672570, 2672579, 2672584, 2672589, 2672601, 2672610, 2672615, 2672620, 2672632, 2672641, 2672646, 2672651, 2672663, 2672672, 2672677, 2672682, 2672694, 2672703, 2672708, 2672713, 2672725, 2672734, 2672739, 2672744, 2672756, 2672765, 2672770, 2672775, 2672787]


noncomputable def cacheAt (a : Nat) : Cache :=
  (cacheTW mlxOf D1PostOne.s10 (.obj a)).getD ⟨[], 0, none, none⟩

noncomputable def sourceCaches : List Cache := cacheObjects.map cacheAt

kernel_rfl source_count : sourceCaches.length = 64
#check source_count

load_cache_carriers source_nodes : sourceCaches, fullExpected.2.2, choice.cert
#check source_nodes

end Host.Ts.Sim.Compose.ColdGraph.OneCache
