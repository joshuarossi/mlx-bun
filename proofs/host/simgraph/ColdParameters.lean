import host.load.run.full.FirstValues
import host.simgraph.GenLoadRel
import host.sim.extract.Grow
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Mlx.SimGraph.ColdParameters
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.GlueStep

/-- The ordinary parameter ancestor fragment has no kernel or runtime-number dependency. -/
def staticByte : Byte → Bool
  | .lit _ => true
  | .part _ (.num (.lit _)) _ => true
  | _ => false

def staticPrim : Ffi.Prim → Bool
  | .data bs => bs.all staticByte
  | .load .. | .binary .. | .transpose .. | .contiguous => true
  | _ => false

def staticNode (bound : Nat) (nd : Ffi.Node) : Bool :=
  nd.shape.all dimLit && staticPrim nd.prim && nd.ins.all (· < bound)

theorem byte_fixed (Mp : Map) (b : Byte) (hb : staticByte b = true) : Mp.byte b = b := by
  cases b with
  | lit _ => rfl
  | part k c i => cases c with
    | big _ => cases hb
    | num x => cases x with
      | ref _ => cases hb
      | lit _ => rfl

theorem prim_fixed (Mp : Map) (p : Ffi.Prim) (hp : staticPrim p = true) : Mp.prim p = p := by
  cases p with
  | data bs =>
    simp only [staticPrim] at hp
    have hb : bs.map Mp.byte = bs := by
      induction bs with
      | nil => rfl
      | cons b bs ih =>
        simp only [List.all_cons, Bool.and_eq_true] at hp
        simp only [List.map_cons, byte_fixed Mp b hp.1, ih hp.2]
    simp only [Map.prim, hb]
  | load f k => rfl
  | binary op => rfl
  | transpose ax => rfl
  | contiguous => rfl
  | _ => cases hp

theorem dims_fixed (Mp : Map) (ds : List Ffi.Dim) (hs : ds.all dimLit = true) : Mp.dims ds = ds := by
  induction ds with
  | nil => rfl
  | cons d ds ih =>
    simp only [List.all_cons, Bool.and_eq_true] at hs
    have hd : Mp.dim d = d := by cases d <;> first | rfl | cases hs.1
    simp only [Map.dims, List.map_cons, hd]
    exact congrArg (d :: ·) (ih hs.2)

theorem static_exact (bound : Nat) (nd : Ffi.Node) (hs : staticNode bound nd = true) :
    G.shapeOnly nd = false := by
  simp only [staticNode, Bool.and_eq_true] at hs
  simp [G.shapeOnly, hs.1.1]

/-- Exact ordinary source nodes retain their ids only inside the explicit fixed band. -/
theorem node_of_MR {P : LoadP} {NB : Nat} {Mp : Map} {n : Nat} {x y : NSt}
    (hr : G.MR P NB Mp n x y) {j : Nat} {nd : Ffi.Node}
    (hj : j < NB) (hn : x.nodes.get j = some nd) (hs : staticNode NB nd = true) :
    y.nodes.get j = some nd := by
  obtain ⟨nd', hy, hsh, hdt, _, hf⟩ := hr.nodes j nd hn
  obtain ⟨hp, hi⟩ := hf (.inl (Nat.lt_of_lt_of_le hj hr.nbl))
  have hprim := hp.exact (static_exact NB nd hs)
  simp only [staticNode, Bool.and_eq_true] at hs
  rw [prim_fixed Mp nd.prim hs.1.2] at hprim
  rw [dims_fixed Mp nd.shape hs.1.1] at hsh
  have fixIns : ∀ (xs : List Nat), xs.all (· < NB) = true → xs.map Mp.node = xs := by
    intro xs hx
    induction xs with
    | nil => rfl
    | cons a xs ih =>
      simp only [List.all_cons, Bool.and_eq_true, decide_eq_true_eq] at hx
      simp only [List.map_cons, hr.nid a hx.1, ih hx.2]
  have hins := fixIns nd.ins hs.2
  rw [hins] at hi
  have he : nd' = nd := by cases nd'; cases nd; simp_all
  rw [hr.nid j hj, he] at hy
  exact hy

theorem byte_server (Cs Ds : CSrv) (b : Byte) (hb : staticByte b = true) :
    concreteByte Cs.val b = concreteByte Ds.val b := by
  cases b with
  | lit _ => rfl
  | part k c i => cases c with
    | big _ => cases hb
    | num x => cases x with
      | ref _ => cases hb
      | lit _ => rfl

theorem bytes_server (Cs Ds : CSrv) (bs : List Byte) (hb : bs.all staticByte = true) :
    bs.mapM (concrete Cs.val).byte = bs.mapM (concrete Ds.val).byte := by
  induction bs with
  | nil => rfl
  | cons b bs ih =>
    simp only [List.all_cons, Bool.and_eq_true] at hb
    have he : (concrete Cs.val).byte b = (concrete Ds.val).byte b := byte_server Cs Ds b hb.1
    rw [List.mapM_cons, List.mapM_cons, he, ih hb.2]

theorem dims_server (Cs Ds : CSrv) (ds : List Ffi.Dim) (hs : ds.all dimLit = true) :
    ds.mapM (concrete Cs.val).d = ds.mapM (concrete Ds.val).d := by
  induction ds with
  | nil => rfl
  | cons d ds ih =>
    simp only [List.all_cons, Bool.and_eq_true] at hs
    have hd : (concrete Cs.val).d d = (concrete Ds.val).d d := by
      cases d with
      | lit _ => rfl
      | sym _ => cases hs.1
    simp only [List.mapM_cons, hd, ih hs.2]

/-- This fragment's resolution uses neither the number server nor kernel objects. -/
theorem resolve_static (Cs Ds : CSrv) (kn kn' : Nat → Option (List Char))
    (bound : Nat) (nd : Ffi.Node) (hs : staticNode bound nd = true) :
    resolveNode (κ := InKey) (concrete Cs.val) kn nd = resolveNode (concrete Ds.val) kn' nd := by
  simp only [staticNode, Bool.and_eq_true] at hs
  have hd := dims_server Cs Ds nd.shape hs.1.1
  have hp := hs.1.2
  cases h : nd.prim with
  | data bs =>
    rw [h] at hp
    have hb := bytes_server Cs Ds bs hp
    simp only [resolveNode, h, resolvePrim, hd, hb]
  | load f k => simp only [resolveNode, h, resolvePrim]
  | binary op => simp only [resolveNode, h, resolvePrim]
  | transpose ax => simp only [resolveNode, h, resolvePrim]
  | contiguous => simp only [resolveNode, h, resolvePrim]
  | _ => rw [h] at hp; cases hp

/-- Transfer just the checked load program; unrelated graph nodes and kernels are irrelevant. -/
theorem matches_transfer (p : Program.Code) (cert : List Nat) (G H : Nat → Option (RNode Int InKey))
    (hm : Matches G (p.map Program.Node.erase) cert = true)
    (he : ∀ i, i < p.length → H (certAt cert i) = G (certAt cert i)) :
    Matches H (p.map Program.Node.erase) cert = true := by
  apply List.all_eq_true.mpr
  intro i hi
  have hil : i < p.length := by simpa using List.mem_range.mp hi
  have hn : p[i]? = some p[i] := List.getElem?_eq_getElem hil
  have old := List.all_eq_true.mp hm i hi
  simp only [List.getElem?_map, hn, Option.map_some] at old ⊢
  generalize hnd : p[i] = nd at old ⊢
  cases nd with
  | mk op ins sh dt => cases op <;> simpa [Program.Node.erase, nodeOk, isInput, FfiEval.isExp, he i hil] using old

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- The target load-program match derives the original checkpoint values, including preprocessing. -/
theorem parameter_values (env : FfiEval.Env InKey) (table : List F64)
    (leaves : Leaves code env.weights) (native : Ffi.St) (Cs : CSrv) (ids : Value)
    (hm : Matches (ffiGraph (κ := InKey) (concrete Cs.val) SourceKernels.sources native)
      (code.map Program.Node.erase) code.cert = true) :
    ∀ u ∈ parameterTensors parameterChoice,
      evalR M K (stepEnvWithIds env.weights (weights (firstValues M K env table)) ids initialHandles)
        (ffiGraph (concrete Cs.val) SourceKernels.sources native) u.node = some (firstValues M K env table u) := by
  intro u hu
  have hc := List.all_eq_true.mp code.covers u hu
  simp only [covered, Bool.and_eq_true, beq_iff_eq] at hc
  let i := code.cert.idxOf u.node
  have hcarrier : certAt code.cert i = u.node := hc.1
  cases hn : code[code.cert.idxOf u.node]? with
  | none => simp only [hn, Bool.false_eq_true, and_false] at hc
  | some nd =>
    have hi : i < code.length := (List.getElem?_eq_some_iff.mp hn).choose
    let env' := stepEnvWithIds env.weights (weights (firstValues M K env table)) ids initialHandles
    have ht := matches_eval M K env' _ _ _ hm (no_inputs M K env'.weights env'.inputs code _ code.cert) i
      (by simpa using hi)
    have hs := matches_eval M K env' _ _ _ (first_load_matches table SourceKernels.sources)
      (no_inputs M K env'.weights env'.inputs code _ code.cert) i (by simpa using hi)
    rw [hcarrier] at ht hs
    have hev := parameter_evaluated M K env (firstFfiGraph table) leaves
      (first_load_matches table SourceKernels.sources) u hu
    have stable := evalFfi_inputs M K env' env rfl (concrete (CSrv.val ⟨table⟩))
      SourceKernels.sources firstChoice.graph u.node
    exact ht.trans (hs.symm.trans (stable.trans hev))
end Host.Mlx.SimGraph.ColdParameters
