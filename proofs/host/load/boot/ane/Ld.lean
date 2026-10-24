import host.load.boot.ane.Check
import host.load.boot.ane.Net
import host.load.boot.Ld
import host.load.run.full.FirstValues
namespace Host.Load.Run.Prompt
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.GlueStep Host.Mlx.SimGraph Host.Mlx.SimGraph.Ref
  Host.Mlx.SimGraph.Mach Host.Load Host.Load.Boot Host.Load.Extract

/-! # The loaded model's Neural Engine side, from the boot's `loadDone`

`aneNetLd c init`: the Neural Engine side (`AneNet`) of the buckets the boot leaves (`aneLd`: the model object's buckets in the load state at `loadDone`) on the bridge it
leaves (`replay P.oblog2818`, the full world's at `loadDone`: `aneNetLd_bridge`), the arrays' values
`headerValues c` (`c`: the arrays' contents, e.g. the graph's `contents M K env G`), the surfaces after
the load `init` (the bridge has run nothing: its memory at `loadDone` is `init`, `aneNetLd_surfaces`).

* `aneNetLd_keys`: only readback keys have splits;
* `aneNetLd_layers`: at every bucket of 224–2048 rows each layer is as the route's family reads it
  (`AneNetLayer`) at the loaded stages, at any contents;
* `aneNetLd_ok`: **`AneNetOk`** at the first forward's loaded stages (`firstValues`), every table. -/

/-- **The loaded model's Neural Engine side.** -/
noncomputable def aneNetLd (c : Nat → Nat → Nat) (init : Nat → Surface) : AneNet :=
  aneNetOf aneLd (replay P.oblog2818) c init

theorem aneNetLd_keys (c : Nat → Nat → Nat) (init : Nat → Surface) (n : Nat) (k : AKey) (sp : SplitSpec)
    (h : (aneNetLd c init).split n k = some sp) : rbLayer k ≠ none :=
  netSplit_keys h

theorem aneNetLd_layers (c c' : Nat → Nat → Nat) (init : Nat → Surface) {n : Nat} (h1 : 224 ≤ n) (h2 : n ≤ 2048)
    {p : Nat} {s : StageWeights} (hs : (stageWeights (Run.Full.weights (headerValues c')))[p]? = some s)
    (h : Handles) : AneNetLayer (aneNetLd c init) n p (aneKindsOf n) (aneRestOf n) (stageLayout s h) := by
  have hp : p < 64 := by
    have := (List.getElem?_eq_some_iff.1 hs).1
    simpa [stageWeights] using this
  have hL : aneLays[p]? = some (laySum s) := by
    rw [← aneLays_any c', List.getElem?_map, hs]
    rfl
  exact aneNetOf_layer aneLd_check c init h1 h2 hp hL h

/-- **The loaded model's Neural Engine side as the route's Neural Engine steps need it**, at the first forward's
loaded stages, every table (`Route.route_final`'s `hnet`). -/
theorem aneNetLd_ok {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (c : Nat → Nat → Nat) (init : Nat → Surface) :
    ∀ tab, AneNetOk (aneNetLd c init) (stageWeights (Run.Full.weights (Run.Full.firstValues M K env tab))) :=
  fun _ => ⟨aneNetLd_keys c init, fun _ h1 h2 _ _ h hs => aneNetLd_layers c _ init h1 h2 hs h⟩

/-! ## The loaded state it is read from -/

/-- The full world's bridge at `loadDone`, every prompt and readback suffix. -/
theorem aneNetLd_bridge (fw : List Host.Ts.Val) (tail : List Host.Ts.NumV) :
    (ldStT fw tail).ffi.1.1.bridge = replay P.oblog2818 := by
  rw [ldStT_layers]

theorem allocAll_log : ∀ (b : FfiAne.St) (ns : List Nat), (FfiAne.allocAll b ns).2.log = b.log
  | _, [] => rfl
  | _, _ :: ns => allocAll_log _ ns

theorem cond_log {b x y : FfiAne.St} (c : Bool) (hx : x.log = b.log) (hy : y.log = b.log) :
    (bif c then x else y).log = b.log := by
  cases c <;> assumption

theorem create_log (b : FfiAne.St) (n : Nat) (args : List Host.Ts.Arg) (share : Option Nat) :
    (FfiAne.create b n args share).log = b.log := by
  unfold FfiAne.create
  split
  · rfl
  · split
    · simp only [FfiAne.addProgram, FfiAne.alloc, allocAll_log]
    · split
      · rfl
      · split
        · rfl
        · exact cond_log _ rfl (cond_log _ rfl rfl)

theorem replay_log : ∀ log : BLog, (replay log).log = []
  | [] => rfl
  | (_, _, _) :: r => (create_log _ _ _ _).trans (replay_log r)

/-- **The surfaces after the load**: the bridge at `loadDone` has run nothing, so its memory holds the
surfaces' initial contents. -/
theorem aneNetLd_surfaces {C : Inference.Contracts.Mlx.M1Max.Contract} (Pm : MlxPrefillContract C)
    (K : RouteKernelContract C) (weights : List Char → List Char → Option Value) (kind : Nat → Option Compiled)
    (NE : NeuralEngine) (IP : InPlace) (G : Graph) (c : Nat → Nat → Nat) (init : Nat → Surface) :
    final Pm K weights kind NE IP G (aneNetLd c init).surfaces (replay P.oblog2818) =
      some ⟨init, fun _ => none, fun _ => none⟩ := by
  unfold final
  rw [replay_log]
  rfl

end Host.Load.Run.Prompt
