import host.simgraph.iter.Final
import host.sim.extract.CacheFinal
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim.ExtractSim (cachesT nodePair cachesAllB cacheOkB)
open Inference.Models.Qwen

/-! # The final cases' goal with the program's final caches

`GFC`: the general theorem's graph conclusions (`GF`) and the time-`T` forward result at
the caches the program's final `cache` binding extracts to (`cachesT`: the cache offsets
are symbolic, and the forward result reads only the tensor nodes). `fgstepC_of` combines
`fgstep_core` (time `T` at the images of the template start's carriers) with
`final_cache` (the target's `cache` binding extracts to caches at those images). -/

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- **The final goal** at the halted end `tF`, read at table `tab`. -/
def GFC (T : Nat) (tab : List F64) (tF : St Sim.LF.S) : Prop :=
  GF M K env leaves typed parameters T tab tF ∧
  ∀ hb : T ≤ 262144, ∃ cs out, cachesT tF (entryEnv Host.Load.Run.Full.P.s0) = some cs ∧
    ForwardAt M K env tab leaves typed (hpOf M K env leaves typed parameters tab) T hb cs out (Gr tab tF.ffi.mlx)

/-- **A final case's graph step with the program's final caches.** -/
theorem fgstepC_of {okA okB : St Sim.LF.S → SSrv → Bool} {s0 : St Sim.LF.S} {tab0 : List SymE} {cE aN : Nat}
    (fixA : List Nat) (fc : Sim.FinalCase okA okB s0 tab0 cE aN) (ρ : Nat → F64) (T : Nat)
    (tk : Nat → Nat) (toks : List NumV)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hT : 2 ≤ T) (hTb : T ≤ 262144)
    (hsA : s0.ffi.mlx.items.get tplInputs.read = none) (hsB : s0.ffi.mlx.items.get tplInputs.fed = none)
    (hpA : (s0.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hpB : (s0.ffi.mlx.nodes.get tplInputs.fed).isSome = true)
    (hfA : fc.sF.ffi.mlx.items.get tplInputs.read = some (.ref 79))
    (hfB : fc.sF.ffi.mlx.items.get tplInputs.fed = some (.ref tab0.length))
    (hpfA : (fc.sF.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hpfB : (fc.sF.ffi.mlx.nodes.get tplInputs.fed).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : fc.sF.ffi.mlx.tokens = [])
    (h79 : nth? fc.SF.tab 79 = some (.var 14)) (h17 : nth? fc.SF.tab tab0.length = some (.var 17))
    (hc : Host.Load.Run.Tpl.cacheCell ∈ fixA)
    (hpres : (fc.sF.heap.get Host.Load.Run.Tpl.cacheCell).isSome = true) {aC : Nat}
    (hbind : bindingOf fc.sF (entryEnv Host.Load.Run.Full.P.s0) chars!"cache" = some (.obj aC))
    (hne : [2673447, 12502, aN].contains aC = false)
    (hok : cachesAllB fc.sF (entryEnv Host.Load.Run.Full.P.s0) cacheOkB = true) {cs : List Cache}
    (hcs : cachesT fc.sF (entryEnv Host.Load.Run.Full.P.s0) = some cs) (hn : cs.map nodePair = tplCaches) :
    Sim.FinalGStep (Gx M K env leaves typed parameters tplInputs) Sim.loadP0 fixA fc ρ T tk toks
      (fun tF CF => GFC M K env leaves typed parameters T CF.tab tF) := by
  intro hlen nx Mp Kc t Cs MF KF tF CF hGx hfixA hst _ _ _ hrun fr hext _ _ hKF hend
  obtain ⟨hgf, hfwd⟩ := fgstep_core M K env leaves typed parameters Sim.loadP0 fc ρ T tk toks tplInputs htk hT hTb
    (by decide) hsA hsB hpA hpB hfA hfB hpfA hpfB hs0tok hsFtok h79 h17 hlen nx Mp Kc t Cs MF KF tF CF hGx hst _
    hrun fr hext hend
  have hfix : MF.a Host.Load.Run.Tpl.cacheCell = Host.Load.Run.Tpl.cacheCell := by
    rw [hext.a]; exact hfixA _ hc
  obtain ⟨cs', hcs', hn'⟩ := Host.Load.Run.Tpl.final_cache hend hfix hKF hpres hbind hne hok hcs hn
  refine ⟨hgf, fun hb => ⟨cs', _, hcs', forwardAt_congr M K env leaves typed hfwd ?_⟩⟩
  rw [cachesAt_nodes]
  exact hn'.symm

end Host.Mlx.SimGraph.Iter
