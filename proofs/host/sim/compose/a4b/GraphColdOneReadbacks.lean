import host.sim.compose.a4b.GraphColdOneMachineCaches
import host.sim.extract.Grow
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.OneReadback
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full
open _root_.Host.Load _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-- Exactly one native read from an empty item trie accounts for the entire final trie. -/
theorem items_exact {s t : _root_.Host.Mlx.Ffi.St} (hg : Ffi.NGrow s t)
    (hempty : s.items = .nil) (hlen : s.tokens.length = t.tokens.length + 1)
    {node : Nat} {value : NumV} (hitem : t.items.get node = some value) :
    t.items = PTrie.nil.set node value := by
  have hnone : s.items.get node = none := by rw [hempty]; rfl
  exact (hg.single hlen hnone hitem).trans (by rw [hempty])

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
    (NE : NeuralEngine) (net : Ref.AneNet) (env : FfiEval.Env InKey) (input : Fin 248320)

/-- Definedness already supplied by the actual graph identifies the route's first token. -/
theorem reference_token {tab : List F64} {token : Nat} {handles : List _root_.Host.Mlx.GlueStep.Handles}
    (href : refPrompt P KR NE KR.inPlace net env [input.val] tab 1 = some (token, handles)) :
    _root_.Host.Route.machTok P KR NE net env [input.val] 1 = token := by
  have h := href
  rw [_root_.Host.Route.refPrompt_table P KR NE net env [input.val] tab] at h
  change ((refPrompt P KR NE KR.inPlace net env [input.val] [] 1).map Prod.fst).getD 0 = token
  rw [h]
  rfl

/-- The structural producer certificate covers every memoized read, including target-only slots. -/
theorem values {x : SegInst FF} {start : _root_.Host.Mlx.Ffi.St}
    (hv : OneMachine.Values P KR NE net env input x.M x.t x.C)
    (hg : Ffi.NGrow start (mlxOf x.t.ffi)) (hempty : start.items = .nil)
    (hlen : start.tokens.length = (mlxOf x.t.ffi).tokens.length + 1)
    (hitem : (mlxOf x.t.ffi).items.get (x.M.node 17776) = some (x.M.nv (.ref 1)))
    (hnum : x.C.val (x.M.nv (.ref 1)) =
      some (F64.ofNat (_root_.Host.Route.machTok P KR NE net env [input.val] 1)))
    (hnode : x.M.node 17776 < 2 ^ 64) :
    ReadbackValues P.toMlxContract KR.toKernelContract env x.C.val
      (ffiGraph (concrete x.C.val) SourceKernels.sources (mlxOf x.t.ffi)) (mlxOf x.t.ffi).items := by
  obtain ⟨token, handles, href, htoken, heval, _⟩ := hv
  have htok := reference_token P KR NE net env input href
  rw [htok] at hnum
  rw [items_exact hg hempty hlen hitem]
  exact ReadbackValues.set P.toMlxContract KR.toKernelContract env x.C.val _
    (ReadbackValues.empty P.toMlxContract KR.toKernelContract env x.C.val _)
    (x.M.node 17776) (x.M.nv (.ref 1)) token hnode (by omega) ⟨heval, hnum⟩

/-- At singleton budget the forward interval consists of time one. -/
theorem graph_goal {x : SegInst FF} {je : _root_.Host.Ts.Env}
    (hc : OneMachineCache.Goal P KR NE net env input x je)
    (hr : ReadbackValues P.toMlxContract KR.toKernelContract env x.C.val
      (ffiGraph (concrete x.C.val) SourceKernels.sources (mlxOf x.t.ffi)) (mlxOf x.t.ffi).items) :
    GFM P.toMlxContract KR.toKernelContract env
      (refPrompt P KR NE KR.inPlace net env [input.val]) 1 1 x.C.tab (mlxOf x.t.ffi) := by
  obtain ⟨cs, out, _, hforward⟩ := hc
  refine ⟨?_, hr⟩
  intro k hlo hhi
  have hk : k = 1 := by omega
  subst k
  exact ⟨cs, out, hforward⟩

end Host.Ts.Sim.Compose.ColdGraph.OneReadback
