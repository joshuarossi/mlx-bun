import host.sim.native.CallS
import host.sim.native.gen.OpSym
import host.sim.native.gen.FfiSim
import host.sim.native.gen.ReplayCall
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! `host.sim.native.CallS` for the general native relation `G.MR` (`host.sim.native.gen.Rel`):
the same statements and proofs, with the pre-load band bound `NB` threaded through. -/

section

variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)

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

section

variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)

include hs hr

theorem sim_sliceS (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.slice)
    {o a st n1 sp n2 sr n3 e : Arg} {ins : List Nat} {d1 d2 d3 s : List Dim} {dt : Nat} (ha : hdOk x a = true)
    (k1 : dimsOk P st n1 = true) (k2 : dimsOk P sp n2 = true) (k3 : dimsOk P sr n3 = true)
    (h1 : Host.Mlx.Ffi.arrIns x [a] = some ins) (e1 : Host.Mlx.Ffi.dimsArg st n1 = some d1)
    (e2 : Host.Mlx.Ffi.dimsArg sp n2 = some d2) (e3 : Host.Mlx.Ffi.dimsArg sr n3 = some d3)
    (ho : NativeOkS.symOk P x o = true) (v1 : d1.all dimOkV = true) (v2 : d2.all dimOkV = true)
    (v3 : d3.all isOne = true) (hsh : Host.Mlx.Ffi.shapesOf x ins = some [(s, dt)]) (vs : s.all dimOkV = true)
    (hsm : ∀ j ∈ smallRefs x name [o, a, st, n1, sp, n2, sr, n3, e], RefSmall ν S j) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, st, n1, sp, n2, sr, n3, e])
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
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, a, u, st, n1, sp, n2, sr, n3, e])
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
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, v, ax, e])
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
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, q, k, v, .num scale, mask, mk, sk, e1, e2])
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

end Host.Ts.Sim.G
