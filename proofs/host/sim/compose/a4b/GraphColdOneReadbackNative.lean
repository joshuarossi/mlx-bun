import host.sim.compose.a4b.GraphColdOneReadbacks
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.OneNativeReadback
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full
open _root_.Host.Load _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
    (NE : NeuralEngine) (net : Ref.AneNet) (env : FfiEval.Env InKey) (input : Fin 248320)

/-- The actual endpoint relation supplies the sampled item, slot bound and numeric image. -/
theorem one {x : SegInst FF} {start : _root_.Host.Mlx.Ffi.St} {LP : LoadP} {NB n : Nat}
    (hR : _root_.Host.Ts.Sim.G.MR LP NB x.M n One.native (mlxOf x.t.ffi))
    (hv : OneMachine.Values P KR NE net env input x.M x.t x.C)
    (hg : Ffi.NGrow start (mlxOf x.t.ffi)) (hempty : start.items = .nil)
    (hlen : start.tokens.length = (mlxOf x.t.ffi).tokens.length + 1)
    (ρ : Nat → F64)
    (hnum : ∀ i e, nth? D1PostOne.S10.tab i = some e →
      x.C.val (x.M.nv (.ref i)) = some (e.eval ρ))
    (h1 : ρ 1 = F64.ofNat (_root_.Host.Route.machTok P KR NE net env [input.val] 1)) :
    ReadbackValues P.toMlxContract KR.toKernelContract env x.C.val
      (ffiGraph (concrete x.C.val) SourceKernels.sources (mlxOf x.t.ffi)) (mlxOf x.t.ffi).items := by
  have hs : One.native.items.get 17776 = some (.ref 1) := D1PostOne.firstRead
  have hp := hR.itemsPresent 17776 (by rw [hs]; rfl)
  have hi := hR.items 17776 hp
  rw [hs, Option.map_some] at hi
  have hb : 17776 < One.native.nnext := by
    rw [show One.native.nnext = 17777 from D1PostOne.nodeCounter]
    decide
  have ht := hR.nall 17776 hb
  have hroom := hR.nroom.2.2
  have hn : x.M.node 17776 < 2 ^ 64 := by omega
  have hv1 := hnum 1 (.var 1) D1PostOne.tokenVar
  change x.C.val (x.M.nv (.ref 1)) = some (ρ 1) at hv1
  rw [h1] at hv1
  exact OneReadback.values P KR NE net env input hv hg hempty hlen hi hv1 hn

/-- EOS uses its own endpoint relation and the proved exact native/table correspondence. -/
theorem eos {x : SegInst FF} {start : _root_.Host.Mlx.Ffi.St} {LP : LoadP} {NB n : Nat}
    (hR : _root_.Host.Ts.Sim.G.MR LP NB x.M n OneEos.native (mlxOf x.t.ffi))
    (hv : OneMachine.Values P KR NE net env input x.M x.t x.C)
    (hg : Ffi.NGrow start (mlxOf x.t.ffi)) (hempty : start.items = .nil)
    (hlen : start.tokens.length = (mlxOf x.t.ffi).tokens.length + 1)
    (ρ : Nat → F64)
    (hnum : ∀ i e, nth? D1PostOneEos.S10.tab i = some e →
      x.C.val (x.M.nv (.ref i)) = some (e.eval ρ))
    (h1 : ρ 1 = F64.ofNat (_root_.Host.Route.machTok P KR NE net env [input.val] 1)) :
    ReadbackValues P.toMlxContract KR.toKernelContract env x.C.val
      (ffiGraph (concrete x.C.val) SourceKernels.sources (mlxOf x.t.ffi)) (mlxOf x.t.ffi).items :=
  one P KR NE net env input (OneEos.native_relation LP NB x.M n (mlxOf x.t.ffi) hR)
    hv hg hempty hlen ρ (fun i e he => hnum i e (by rw [OneEos.table_same]; exact he)) h1

end Host.Ts.Sim.Compose.ColdGraph.OneNativeReadback
