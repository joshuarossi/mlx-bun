import host.sim.native.OpSym
import host.sim.native.FfiSim
import host.sim.native.ReplayCall
import host.sim.FfiCall
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf Out)

/-! # `FfiCallSim` for the load world: the symbolic decode calls

`okCallS P` extends `okCall P` by the KV-cache calls on symbolic shapes —
unit-stride slices and slice updates whose dimensions are naturals or number
references, two-input concatenation, attention on any input shapes — and by
compiled-closure applies (`NativeOk.clApply`). Their numeric premise
`smallLoad`: every number reference among the decoded dimensions and the input
shapes of a slice, slice update or concatenation denotes, at the valuation, a
natural below `2 ^ 31` (`RefSmall`). -/

/-! ## Dimensions with small values -/

def dimOkV : Dim → Bool
  | .lit i => decide (0 ≤ i ∧ i < 2 ^ 31)
  | .sym (.ref _) => true
  | .sym (.lit _) => false

def dimRefs : Dim → List Nat
  | .sym (.ref j) => [j]
  | _ => []

/-- Number reference `j` denotes a natural below `2 ^ 31` at `ν`. -/
def RefSmall (ν : Nat → F64) (S : SSrv) (j : Nat) : Prop :=
  ∃ e k, nth? S.tab j = some e ∧ e.eval ν = F64.ofNat k ∧ k < 2 ^ 31

section
variable {ν : Nat → F64} {M : Map} {S : SSrv} {C : CSrv}

theorem dvs_of (hs : Srv M ν S C) {d : Dim} (hv : dimOkV d = true) (hsm : ∀ j ∈ dimRefs d, RefSmall ν S j) :
    ∃ k, DVS M C S d k ∧ k < 2 ^ 31 := by
  cases d with
  | lit i =>
    simp only [dimOkV, decide_eq_true_eq] at hv
    refine ⟨i.toNat, ⟨.inl ?_, trivial⟩, by omega⟩
    rw [Int.toNat_of_nonneg hv.1]
  | sym v =>
    cases v with
    | lit _ => cases hv
    | ref j =>
      obtain ⟨e, k, he, hev, hk⟩ := hsm j (by simp [dimRefs])
      refine ⟨k, ⟨.inr ⟨j, rfl, ?_⟩, nth?_lt _ _ _ he⟩, hk⟩
      rw [hs.num j e he, hev]

theorem dvss_of (hs : Srv M ν S C) : ∀ {ds : List Dim}, ds.all dimOkV = true →
    (∀ j ∈ ds.flatMap dimRefs, RefSmall ν S j) → ∃ ks, DVSs M C S ds ks ∧ Bd ks
  | [], _, _ => ⟨[], trivial, fun _ h => by cases h⟩
  | d :: ds, hv, hsm => by
    simp only [List.all_cons, Bool.and_eq_true] at hv
    obtain ⟨k, hk, bk⟩ := dvs_of hs hv.1 fun j hj => hsm j (by simp only [List.flatMap_cons]; exact List.mem_append_left _ hj)
    obtain ⟨ks, hks, bks⟩ := dvss_of hs hv.2 fun j hj => hsm j (by simp only [List.flatMap_cons]; exact List.mem_append_right _ hj)
    exact ⟨k :: ks, ⟨hk, hks⟩, Bd.cons.mpr ⟨bk, bks⟩⟩
end

/-! ## The checks -/

def isOne (d : Dim) : Bool := decide (d = .lit 1)

/-- The references of input shapes. -/
def shRefs (x : NSt) (ins : List Nat) : List Nat :=
  match Host.Mlx.Ffi.shapesOf x ins with
  | some sh => sh.flatMap fun p => p.1.flatMap dimRefs
  | none => []

def dimsArgRefs (p c : Arg) : List Nat :=
  match Host.Mlx.Ffi.dimsArg p c with
  | some ds => ds.flatMap dimRefs
  | none => []

namespace NativeOkS
variable (P : LoadP) (x : NSt)

def symOk (o : Arg) : Bool := slotOk P x o && decide (x.next + 1 ≤ P.E) && decide (x.nnext + 1 ≤ P.NE)

def slice : List Arg → Bool
  | [o, a, st, n1, sp, n2, sr, n3, _] => hdOk x a && dimsOk P st n1 && dimsOk P sp n2 && dimsOk P sr n3 &&
    match Host.Mlx.Ffi.arrIns x [a], Host.Mlx.Ffi.dimsArg st n1, Host.Mlx.Ffi.dimsArg sp n2,
      Host.Mlx.Ffi.dimsArg sr n3 with
    | some ins, some d1, some d2, some d3 => symOk P x o && d1.all dimOkV && d2.all dimOkV && d3.all isOne &&
      match Host.Mlx.Ffi.shapesOf x ins with
      | some [(s, _)] => s.all dimOkV
      | _ => false
    | _, _, _, _ => false
  | _ => false

def sliceUpdate : List Arg → Bool
  | [o, a, u, st, n1, sp, n2, sr, n3, _] => hdOk x a && hdOk x u && dimsOk P st n1 && dimsOk P sp n2 &&
    dimsOk P sr n3 &&
    match Host.Mlx.Ffi.arrIns x [a, u], Host.Mlx.Ffi.dimsArg st n1, Host.Mlx.Ffi.dimsArg sp n2,
      Host.Mlx.Ffi.dimsArg sr n3 with
    | some ins, some d1, some d2, some d3 => symOk P x o && d1.all dimOkV && d2.all dimOkV && d3.all isOne &&
      match Host.Mlx.Ffi.shapesOf x ins with
      | some [(s, _), (u, _)] => s.all dimOkV && u.all dimOkV
      | _ => false
    | _, _, _, _ => false
  | _ => false

def concat : List Arg → Bool
  | [o, v, ax, _] => hdOk x v && natOk P ax &&
    match (Host.Mlx.Ffi.argNat v).bind x.obj? with
    | some (.vec (i :: rest)) => match x.nodes.get i, Host.Mlx.Ffi.argInt ax with
      | some nd, some a => match Host.Mlx.Ffi.axisOf a (len nd.shape) with
        | some _ => symOk P x o && match Host.Mlx.Ffi.shapesOf x (i :: rest) with
          | some [(s1, _), (s2, _)] => s1.all dimOkV && s2.all dimOkV
          | _ => false
        | none => false
      | _, _ => false
    | _ => false
  | _ => false

def sdpa : List Arg → Bool
  | [o, q, k, v, .num _, mask, mk, sk, _, _] => hdOk x q && hdOk x k && hdOk x v && natOk P mk && natOk P sk &&
    match Host.Mlx.Ffi.arrIns x [q, k, v], Host.Mlx.Ffi.cstrArg mask, Host.Mlx.Ffi.argNat mk,
      Host.Mlx.Ffi.argNat sk with
    | some ins, some _, some 0, some 0 => symOk P x o && match Host.Mlx.Ffi.shapesOf x ins with
      | some [_, _, _] => true
      | _ => false
    | _, _, _, _ => false
  | _ => false

def sym : Host.Mlx.Ffi.Sym → List Arg → Bool
  | .slice => slice P x
  | .sliceUpdate => sliceUpdate P x
  | .concat => concat P x
  | .sdpa => sdpa P x
  | .closureApply => NativeOk.clApply P x
  | _ => fun _ => false
end NativeOkS

/-- **The accepted native calls**, with the symbolic decode calls. -/
def okCallS (P : LoadP) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Bool :=
  okCall P x name args || (Host.Load.isMlx name && match Host.Mlx.Ffi.symOf name with
    | some s => NativeOkS.sym P x.mlx s args
    | none => false)

def sliceRefs (x : NSt) : List Arg → List Nat
  | [_, a, st, n1, sp, n2, _, _, _] =>
    (match Host.Mlx.Ffi.arrIns x [a] with
      | some ins => shRefs x ins
      | none => []) ++ dimsArgRefs st n1 ++ dimsArgRefs sp n2
  | _ => []

def sliceUpdateRefs (x : NSt) : List Arg → List Nat
  | [_, a, u, st, n1, sp, n2, _, _, _] =>
    (match Host.Mlx.Ffi.arrIns x [a, u] with
      | some ins => shRefs x ins
      | none => []) ++ dimsArgRefs st n1 ++ dimsArgRefs sp n2
  | _ => []

def concatRefs (x : NSt) : List Arg → List Nat
  | [_, v, _, _] =>
    match (Host.Mlx.Ffi.argNat v).bind x.obj? with
    | some (.vec ns) => shRefs x ns
    | _ => []
  | _ => []

def smallRefsS (x : NSt) : Host.Mlx.Ffi.Sym → List Arg → List Nat
  | .slice => sliceRefs x
  | .sliceUpdate => sliceUpdateRefs x
  | .concat => concatRefs x
  | _ => fun _ => []

/-- The number references a symbolic call's shapes depend on. -/
def smallRefs (x : NSt) (name : Name) (args : List Arg) : List Nat :=
  match Host.Mlx.Ffi.symOf name with
  | some s => smallRefsS x s args
  | none => []

theorem smallRefs_eq {x : NSt} {name : Name} {s : Host.Mlx.Ffi.Sym} (h : Host.Mlx.Ffi.symOf name = some s)
    (args : List Arg) : smallRefs x name args = smallRefsS x s args := by
  unfold smallRefs; rw [h]

/-- **The numeric premise of the load world's native calls.** -/
def smallLoad (ν : Nat → F64) (S : SSrv) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Prop :=
  ∀ j ∈ smallRefs x.mlx name args, RefSmall ν S j

/-! ## Shapes of present inputs -/

section
variable {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (hr : MR P M n x y)
include hr

theorem MR.shapesOf_props : ∀ {ins : List Nat} {sh : List (List Dim × Nat)},
    Host.Mlx.Ffi.shapesOf x ins = some sh → ∀ p ∈ sh, SDs (· < n) p.1 ∧ ∀ d ∈ p.1, DimCanon M d
  | [], sh, h => by
    simp only [Host.Mlx.Ffi.shapesOf, Option.some.injEq] at h; subst h; intro p hp; cases hp
  | i :: ins, sh, h => by
    simp only [Host.Mlx.Ffi.shapesOf] at h
    cases hn : x.nodes.get i with
    | none => rw [hn] at h; cases h
    | some nd =>
      rw [hn] at h
      cases hs : Host.Mlx.Ffi.shapesOf x ins with
      | none => rw [hs] at h; cases h
      | some sh' =>
        rw [hs] at h
        simp only [Option.bind_some, Option.map_some, Option.some.injEq] at h
        subst h
        intro p hp
        rcases List.mem_cons.mp hp with rfl | hp
        · obtain ⟨nd', -, -, -, hc, -⟩ := hr.nodes i nd hn
          exact ⟨(hr.cl.1 i nd hn).2, hc⟩
        · exact shapesOf_props hs p hp
end

theorem shRefs_mem {x : NSt} {ins : List Nat} {sh : List (List Dim × Nat)} (h : Host.Mlx.Ffi.shapesOf x ins = some sh)
    {s : List Dim} {d : Nat} (hm : (s, d) ∈ sh) {j : Nat} (hj : j ∈ s.flatMap dimRefs) : j ∈ shRefs x ins := by
  simp only [shRefs, h]
  exact List.mem_flatMap.mpr ⟨(s, d), hm, hj⟩

theorem dimsArgRefs_mem {p c : Arg} {ds : List Dim} (h : Host.Mlx.Ffi.dimsArg p c = some ds) {j : Nat}
    (hj : j ∈ ds.flatMap dimRefs) : j ∈ dimsArgRefs p c := by
  simp only [dimsArgRefs, h]; exact hj

theorem all_isOne {ds : List Dim} (h : ds.all isOne = true) : ∀ k ∈ ds, k = .lit 1 := fun k hk => by
  have := List.all_eq_true.mp h k hk
  simpa [isOne] using this

/-! ## The calls -/

section
variable {P : LoadP} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P M S.tab.length x y)
include hs hr

theorem sim_sliceS (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.slice)
    {o a st n1 sp n2 sr n3 e : Arg} {ins : List Nat} {d1 d2 d3 s : List Dim} {dt : Nat} (ha : hdOk x a = true)
    (k1 : dimsOk P st n1 = true) (k2 : dimsOk P sp n2 = true) (k3 : dimsOk P sr n3 = true)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (e1 : Host.Mlx.Ffi.dimsArg st n1 = some d1)
    (e2 : Host.Mlx.Ffi.dimsArg sp n2 = some d2) (e3 : Host.Mlx.Ffi.dimsArg sr n3 = some d3)
    (ho : NativeOkS.symOk P x o = true) (v1 : d1.all dimOkV = true) (v2 : d2.all dimOkV = true)
    (v3 : d3.all isOne = true) (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, dt)]) (vs : s.all dimOkV = true)
    (hsm : ∀ j ∈ smallRefs x name [o, a, st, n1, sp, n2, sr, n3, e], RefSmall ν S j) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, st, n1, sp, n2, sr, n3, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg st, M.arg n1, M.arg sp, M.arg n2, M.arg sr, M.arg n3,
        M.arg e]) := by
  rw [smallRefs_eq hsym] at hsm
  simp only [smallRefsS, sliceRefs, h1] at hsm
  obtain ⟨ks, hks, bks⟩ := dvss_of hs vs fun j hj =>
    hsm j (List.mem_append_left _ (List.mem_append_left _ (shRefs_mem hsh (List.mem_singleton_self _) hj)))
  obtain ⟨k1s, hk1, bk1⟩ := dvss_of hs v1 fun j hj =>
    hsm j (List.mem_append_left _ (List.mem_append_right _ (dimsArgRefs_mem e1 hj)))
  obtain ⟨k2s, hk2, bk2⟩ := dvss_of hs v2 fun j hj => hsm j (List.mem_append_right _ (dimsArgRefs_mem e2 hj))
  have h3 := all_isOne v3
  simp only [NativeOkS.symOk, Bool.and_eq_true, decide_eq_true_eq] at ho
  have t1 := hr.arrIns_some (as := [a]) (by simp [ha]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, e1, e2, e3, hr.dimsArg_map k1 e1, hr.dimsArg_map k2 e2, hr.dimsArg_map k3 e3]
  have sd3 : SDs (· < S.tab.length) d3 := fun d hd => by rw [h3 d hd]; trivial
  exact sim_opOutS hs hr ho.1.1 ho.1.2 ho.2 ⟨DVSs.sds hk1, DVSs.sds hk2, sd3⟩ hsh
    (infer_slice_simV hs hks hk1 hk2 bks bk1 bk2 h3)

theorem sim_sliceUpdateS (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.sliceUpdate)
    {o a u st n1 sp n2 sr n3 e : Arg} {ins : List Nat} {d1 d2 d3 s su : List Dim} {dt du : Nat}
    (ha : hdOk x a = true) (hu : hdOk x u = true)
    (k1 : dimsOk P st n1 = true) (k2 : dimsOk P sp n2 = true) (k3 : dimsOk P sr n3 = true)
    (h1 : Host.Mlx.Ffi.arrIns x [a, u] = some ins) (e1 : Host.Mlx.Ffi.dimsArg st n1 = some d1)
    (e2 : Host.Mlx.Ffi.dimsArg sp n2 = some d2) (e3 : Host.Mlx.Ffi.dimsArg sr n3 = some d3)
    (ho : NativeOkS.symOk P x o = true) (v1 : d1.all dimOkV = true) (v2 : d2.all dimOkV = true)
    (v3 : d3.all isOne = true) (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, dt), (su, du)])
    (vs : s.all dimOkV = true) (vu : su.all dimOkV = true)
    (hsm : ∀ j ∈ smallRefs x name [o, a, u, st, n1, sp, n2, sr, n3, e], RefSmall ν S j) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, u, st, n1, sp, n2, sr, n3, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg a, M.arg u, M.arg st, M.arg n1, M.arg sp, M.arg n2, M.arg sr,
        M.arg n3, M.arg e]) := by
  rw [smallRefs_eq hsym] at hsm
  simp only [smallRefsS, sliceUpdateRefs, h1] at hsm
  obtain ⟨ks, hks, bks⟩ := dvss_of hs vs fun j hj =>
    hsm j (List.mem_append_left _ (List.mem_append_left _ (shRefs_mem hsh (d := dt) (by simp) hj)))
  obtain ⟨kus, hku, bku⟩ := dvss_of hs vu fun j hj =>
    hsm j (List.mem_append_left _ (List.mem_append_left _ (shRefs_mem hsh (d := du) (by simp) hj)))
  obtain ⟨k1s, hk1, bk1⟩ := dvss_of hs v1 fun j hj =>
    hsm j (List.mem_append_left _ (List.mem_append_right _ (dimsArgRefs_mem e1 hj)))
  obtain ⟨k2s, hk2, bk2⟩ := dvss_of hs v2 fun j hj => hsm j (List.mem_append_right _ (dimsArgRefs_mem e2 hj))
  have h3 := all_isOne v3
  simp only [NativeOkS.symOk, Bool.and_eq_true, decide_eq_true_eq] at ho
  have t1 := hr.arrIns_some (as := [a, u]) (by simp [ha, hu]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, e1, e2, e3, hr.dimsArg_map k1 e1, hr.dimsArg_map k2 e2, hr.dimsArg_map k3 e3]
  have sd3 : SDs (· < S.tab.length) d3 := fun d hd => by rw [h3 d hd]; trivial
  exact sim_opOutS hs hr ho.1.1 ho.1.2 ho.2 ⟨DVSs.sds hk1, DVSs.sds hk2, sd3⟩ hsh
    (infer_sliceUpdate_simV hs hks hku hk1 hk2 bks bku bk1 bk2 h3)

theorem sim_concatS (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.concat)
    {o v ax e : Arg} {i : Nat} {rest : List Nat} {nd : Node} {a : Int} {b : Nat} {s1 s2 : List Dim} {d1 d2 : Nat}
    (hv : hdOk x v = true) (hax : natOk P ax = true)
    (h3 : (Host.Mlx.Ffi.argNat v).bind x.obj? = some (.vec (i :: rest))) (hn : x.nodes.get i = some nd)
    (hai : Host.Mlx.Ffi.argInt ax = some a) (hb : Host.Mlx.Ffi.axisOf a (len nd.shape) = some b)
    (ho : NativeOkS.symOk P x o = true) (hsh : Host.Mlx.Ffi.shapesOf x (i :: rest) = some [(s1, d1), (s2, d2)])
    (v1 : s1.all dimOkV = true) (v2 : s2.all dimOkV = true)
    (hsm : ∀ j ∈ smallRefs x name [o, v, ax, e], RefSmall ν S j) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, v, ax, e])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg v, M.arg ax, M.arg e]) := by
  rw [smallRefs_eq hsym] at hsm
  simp only [smallRefsS, concatRefs, h3] at hsm
  obtain ⟨k1, hk1, bk1⟩ := dvss_of hs v1 fun j hj => hsm j (shRefs_mem hsh (d := d1) (by simp) hj)
  obtain ⟨k2, hk2, bk2⟩ := dvss_of hs v2 fun j hj => hsm j (shRefs_mem hsh (d := d2) (by simp) hj)
  simp only [NativeOkS.symOk, Bool.and_eq_true, decide_eq_true_eq] at ho
  obtain ⟨k, rfl, hp, hm⟩ := hr.hdOk_spec hv
  rw [argNat_nat, Option.bind_some] at h3
  have h4 : y.obj? (M.handle k) = some (.vec ((i :: rest).map M.node)) := by rw [hr.obj? hp, h3]; rfl
  obtain ⟨nd', h1, h2, -, -⟩ := hr.nodes i nd hn
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, Option.bind_some, h3, h4, hr.argInt_eq hax, hai, List.map_cons, hn, h1, h2, Map.dims,
    Native.len_map, hb]
  exact sim_opOutS (p := .concat b) (ins := i :: rest) hs hr ho.1.1 ho.1.2 ho.2 trivial hsh
    (infer_concat2_simV b hs hk1 hk2 bk1 bk2)

theorem sim_sdpaS (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.sdpa)
    {o q k v mask mk sk e1 e2 : Arg} {scale : NumV} {ins : List Nat} {m : List Char} {sq sk' sv : List Dim}
    {dq dk dv : Nat} (hq : hdOk x q = true) (hk : hdOk x k = true) (hv : hdOk x v = true) (hmk : natOk P mk = true)
    (hsk : natOk P sk = true) (hsc : SN (· < S.tab.length) scale)
    (h1 : Host.Mlx.Ffi.arrIns x [q, k, v] = some ins) (hm : Host.Mlx.Ffi.cstrArg mask = some m)
    (h0 : Host.Mlx.Ffi.argNat mk = some 0) (h0' : Host.Mlx.Ffi.argNat sk = some 0)
    (ho : NativeOkS.symOk P x o = true) (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(sq, dq), (sk', dk), (sv, dv)]) :
    MSim (MPost P M ν S C) S C (Host.Mlx.Ffi.call x name [o, q, k, v, .num scale, mask, mk, sk, e1, e2])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg q, M.arg k, M.arg v, .num (M.nv scale), M.arg mask, M.arg mk,
        M.arg sk, M.arg e1, M.arg e2]) := by
  simp only [NativeOkS.symOk, Bool.and_eq_true, decide_eq_true_eq] at ho
  have pq := hr.shapesOf_props hsh (sq, dq) (by simp)
  have pv := hr.shapesOf_props hsh (sv, dv) (by simp)
  have t1 := hr.arrIns_some (as := [q, k, v]) (by simp [hq, hk, hv]) h1
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [List.map_cons, List.map_nil] at t1
  simp only [h1, t1, cstrArg_map, hm, hr.natOk_argNat hmk, hr.natOk_argNat hsk, h0, h0']
  exact sim_opOutS hs hr ho.1.1 ho.1.2 ho.2 hsc hsh (infer_sdpa_simV hs pq.1 pv.1 pq.2 pv.2)
end

end Host.Ts.Sim
