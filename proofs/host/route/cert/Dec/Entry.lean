import host.sim.compose.Loop
import host.sim.full.BridgeFrame
import host.sim.conv.CompactShift
import host.sim.compose.FullGraph
import host.simgraph.Domain
import host.sim.template.a4dec4_ord.EFacts
import host.load.run.prompt.Addr
import host.route.DecVal
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Route.Cert.Dec
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Load.Layers

/-! # The decode chains' common start

The template `DT4` with only its live readback token: the start of all four chains, its loop facts and its graph facts. -/

abbrev Pw : LoadP := Host.Load.Run.Tpl.DEC4_ord.PE
noncomputable abbrev s0 : St FF.S := Host.Load.Run.Tpl.DEC4_ord.s0
noncomputable abbrev tab0 : List SymE := Host.Load.Run.Tpl.DEC4_ord.S0.tab

kernel_rfl startTok : (mlxOf s0.ffi).tokens = [.ref Host.Load.Run.Prompt.addrPrompt.tok]
kernel_rfl startBig : bigsOutB (mlxOf s0.ffi).next Pw.E (mlxOf s0.ffi) = true
kernel_rfl startRoots : noBigRootsP
    (fun i => !Conv.oldBigB (⟨29302, 22539, 3123568, 179⟩ : Conv.Cnt) i) s0.trace s0 = true

/-- The loop start facts at the source entry, for every pinned bridge. -/
theorem start (b0 : BSt) (NB : Nat) : LoopStartW (fullWorldFb b0 NB) Host.Load.Run.Prompt.addrPrompt Pw s0 tab0 where
  htok := by decide +kernel
  start := ⟨startTok, startBig,
    Conv.jclean_noBigSt Host.Load.Run.Tpl.DEC4_ord.jclean0 (by decide +kernel) (by decide) startRoots⟩
  lo := by
    change Pw.lo ≤ (mlxOf s0.ffi).next
    decide +kernel
  hi := by
    change Pw.E ≤ 2 ^ 56
    decide

/-- Cache carriers extracted from the decode entry, in stage order. -/
def cacheNodes : List (Option Nat × Option Nat) := [
    (some 20171, some 20186), (some 20208, some 20223), (some 20245, some 20260), (some 20291, some 20292),
    (some 20319, some 20334), (some 20356, some 20371), (some 20393, some 20408), (some 20439, some 20440),
    (some 20467, some 20482), (some 20504, some 20519), (some 20541, some 20556), (some 20587, some 20588),
    (some 20615, some 20630), (some 20652, some 20667), (some 20689, some 20704), (some 20735, some 20736),
    (some 20763, some 20778), (some 20800, some 20815), (some 20837, some 20852), (some 20883, some 20884),
    (some 20911, some 20926), (some 20948, some 20963), (some 20985, some 21000), (some 21031, some 21032),
    (some 21059, some 21074), (some 21096, some 21111), (some 21133, some 21148), (some 21179, some 21180),
    (some 21207, some 21222), (some 21244, some 21259), (some 21281, some 21296), (some 21327, some 21328),
    (some 21355, some 21370), (some 21392, some 21407), (some 21429, some 21444), (some 21475, some 21476),
    (some 21503, some 21518), (some 21540, some 21555), (some 21577, some 21592), (some 21623, some 21624),
    (some 21651, some 21666), (some 21688, some 21703), (some 21725, some 21740), (some 21771, some 21772),
    (some 21799, some 21814), (some 21836, some 21851), (some 21873, some 21888), (some 21919, some 21920),
    (some 21947, some 21962), (some 21984, some 21999), (some 22021, some 22036), (some 22067, some 22068),
    (some 22095, some 22110), (some 22132, some 22147), (some 22169, some 22184), (some 22215, some 22216),
    (some 22243, some 22258), (some 22280, some 22295), (some 22317, some 22332), (some 22363, some 22364),
    (some 22391, some 22406), (some 22428, some 22443), (some 22465, some 22480), (some 22511, some 22512)]

/-- The program's cache cell, read through the template projection. -/
noncomputable def sourceCacheNodes : Option (List (Option Nat × Option Nat)) :=
  let s := Template.fullWorld.proj s0
  (((s.cell? Host.Load.Run.Prompt.addrPrompt.cache).bind id).bind
    (Host.Load.Extract.elements s)).bind fun vs =>
      (vs.mapM (Host.Mlx.SimGraph.cacheT s)).map fun cs =>
        cs.map fun c => (c.first.map Host.Load.Extract.Tensor.node, c.second.map Host.Load.Extract.Tensor.node)

kernel_rfl sourceCacheNodes_eq : sourceCacheNodes = some cacheNodes
kernel_rfl startNnext : (mlxOf s0.ffi).nnext = 22539
kernel_rfl startReadUnread : (mlxOf s0.ffi).items.get 20157 = none
kernel_rfl startReadPresent : ((mlxOf s0.ffi).nodes.get 20157).isSome = true
kernel_rfl startFedUnread : (mlxOf s0.ffi).items.get 22538 = none
kernel_rfl startFedPresent : ((mlxOf s0.ffi).nodes.get 22538).isSome = true
kernel_rfl startTokenVar : nth? tab0 Host.Load.Run.Prompt.addrPrompt.tok =
    some (.var Host.Load.Run.Prompt.addrPrompt.kvar)
kernel_rfl startTimeVar : nth? tab0 10 = some (.var Host.Load.Run.Prompt.addrPrompt.tvar)
kernel_rfl startCachesBelow : cacheNodes.all (fun p =>
    (p.1.all fun j => Nat.blt j 22539) && (p.2.all fun j => Nat.blt j 22539)) = true

/-- Where the template holds each abstracted dim. -/
def pinIndex (q : Nat) : Nat := bif Nat.ble q 109 then q + 69 else q + 9

kernel_rfl tab0_pins : (List.range 162).all (fun q =>
    (Host.Load.Run.Tpl.decVal q).isNone || decide (nth? tab0 (pinIndex q) = some (.var q))) = true

/-- The template holds each abstracted dim as its variable. -/
theorem tab0_pin (q k : Nat) (h : Host.Load.Run.Tpl.decVal q = some k) : ∃ j, nth? tab0 j = some (.var q) := by
  have hr := Host.Route.decVal_range h
  have hc := List.all_eq_true.mp tab0_pins q (List.mem_range.mpr (by omega))
  rw [h] at hc
  exact ⟨pinIndex q, by simpa using hc⟩

/-- All cache carriers of the entry lie below its native node counter. -/
theorem startCacheBound : ∀ p ∈ cacheNodes, ∀ j,
    (p.1 = some j ∨ p.2 = some j) → j < (mlxOf s0.ffi).nnext := by
  intro p hp j hj
  have hb := List.all_eq_true.mp startCachesBelow p hp
  simp only [Bool.and_eq_true] at hb
  rw [startNnext]
  rcases hj with hj | hj
  · have h := hb.1
    rw [hj] at h
    exact Nat.blt_eq.mp h
  · have h := hb.2
    rw [hj] at h
    exact Nat.blt_eq.mp h

/-- The decode entry's inputs, shared by all four cases. -/
def inputs : Host.Mlx.SimGraph.Iter.TplInputs := ⟨cacheNodes, 20157, 22538⟩

/-- The common decode start graph facts at the full-world projection. -/
theorem startGM (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    StartGM (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt Pw s0 tab0 inputs where
  hPNL _ := rfl
  hPN0 _ := rfl
  hPE := by
    change Pw.E ≤ Host.Load.Run.Prompt.addrPrompt.rope
    decide
  hrope := by decide
  htv := ⟨10, startTimeVar⟩
  carR := by
    change 20157 < (mlxOf s0.ffi).nnext
    rw [startNnext]
    decide
  carF := by
    change 22538 < (mlxOf s0.ffi).nnext
    rw [startNnext]
    decide
  carC := startCacheBound
  sread := startReadUnread
  pread := startReadPresent
  sfed := startFedUnread
  pfed := startFedPresent
  ne := by decide
  s0tok := startTok
  tokv := startTokenVar

end Host.Route.Cert.Dec
