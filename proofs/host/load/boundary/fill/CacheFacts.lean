import host.load.boundary.fill.Carriers
import host.load.CacheCarriersCommand
import host.load.CachedGrowthShapes
import host.load.run.full.CachedLayout
namespace Host.Load.Run.Full.Fill64
open Host.Ts Host.Load.Extract Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-- The source lookahead result is stored in nextPending; the immediate
read still observes cur, as required by the generator's delayed pipeline. -/
theorem selected_lookahead_node :
    ((s1491.cell? 2673320).join.bind (Extract.tensor s1491)).map Tensor.node = some 24887 := rfl

theorem current_read_node :
    (Host.Load.CacheBoundary.itemInput s1491).map Tensor.node = some 22538 := rfl

theorem output_token : certAt carriers Expected.tokenNode = 24887 := rfl

theorem original : stepGraph Expected.stages Expected.head 255 =
    (Expected.graph,Expected.tokenNode,Expected.cacheOutputs) := Expected.graph_original

load_cache_carriers cache_carriers : after.cache, Expected.cacheOutputs, carriers

theorem before_capacities_derived (table : List F64) :
    Host.Load.CachedGrowthShapes.checkCaches (graph table) .bfloat16 256 12 before.cache = true := by rfl

theorem classes_before (contents : Nat → Nat → Nat) :
    List.Forall₂ CacheClassMatches (stageWeights (weights (headerValues contents))) before.cache := by
  repeat' first | apply List.Forall₂.cons | exact List.Forall₂.nil | rfl

theorem classes_after (contents : Nat → Nat → Nat) :
    List.Forall₂ CacheClassMatches (stageWeights (weights (headerValues contents))) after.cache := by
  repeat' first | apply List.Forall₂.cons | exact List.Forall₂.nil | rfl

theorem capacities_derived (table : List F64) :
    Host.Load.CachedGrowthShapes.checkCaches (graph table) .bfloat16 256 12 after.cache = true := by rfl
end Host.Load.Run.Full.Fill64
