import host.ts.RenameNumbers
namespace Host.Ts

/-! Heap observations and pure control transitions of the actual interpreter. -/

namespace Renamed

theorem obj? {S : Type} {FR : Ren → S → S → Prop} {R : Ren} {tb tb' : List Event}
    {s s' : St S} (h : Renamed FR R tb tb' s s') {a : Nat} (ha : a < s.next) :
    s'.obj? (R.a a) = (s.obj? a).map R.obj := by
  unfold St.obj?
  rw [h.heap a ha]
  cases hh : s.heap.get a with
  | none => rfl
  | some o => cases o <;> rfl

theorem cell? {S : Type} {FR : Ren → S → S → Prop} {R : Ren} {tb tb' : List Event}
    {s s' : St S} (h : Renamed FR R tb tb' s s') {a : Nat} (ha : a < s.next) :
    s'.cell? (R.a a) = (s.cell? a).map (Option.map R.val) := by
  unfold St.cell?
  rw [h.heap a ha]
  cases hh : s.heap.get a with
  | none => rfl
  | some o => cases o <;> rfl

/-- Updating only control and stack preserves all heap, allocation, trace and FFI facts. -/
theorem control {S : Type} {FR : Ren → S → S → Prop} {R : Ren} {tb tb' : List Event}
    {s s' : St S} (h : Renamed FR R tb tb' s s') (c : Ctl) (fs : List Frame)
    (hc : AddrSupported s.next (fun Q => Q.ctl c))
    (hf : AddrSupported s.next (fun Q => fs.map Q.frame)) :
    Renamed FR R tb tb' { s with ctl := c, stack := fs }
      { s' with ctl := R.ctl c, stack := fs.map R.frame } :=
  { h with ctl := rfl, stack := rfl, closed := { h.closed with ctl := hc, stack := hf } }

theorem typeofStr {S : Type} {FR : Ren → S → S → Prop} {R : Ren} {tb tb' : List Event}
    {s s' : St S} (h : Renamed FR R tb tb' s s') (v : Val)
    (hv : ∀ a, v = .obj a → a < s.next) :
    Host.Ts.typeofStr s' (R.val v) = Host.Ts.typeofStr s v := by
  cases v with
  | obj a =>
    have ho := h.obj? (hv a rfl)
    simp only [Ren.val, Host.Ts.typeofStr, ho]
    cases hs : s.obj? a with
    | none => rfl
    | some o =>
      obtain ⟨k, p, ps, pr, ex⟩ := o
      cases k <;> rfl
  | _ => rfl

end Renamed

theorem typeofStr_control {S : Type} (s : St S) (c : Ctl) (fs : List Frame) (v : Val) :
    typeofStr { s with ctl := c, stack := fs } v = typeofStr s v := by
  cases v <;> rfl

/-- `typeof` on a returning value commutes with the actual machine step. Dangling values
are excluded by the explicit allocation bound; the regression in RenameCounterexample
shows why that bound and exact heap lookup are necessary. -/
theorem step_typeof_renamed (F : Ffi) {FR : Ren → F.S → F.S → Prop} {R : Ren}
    {tb tb' : List Event} {s s' : St F.S} (h : Renamed FR R tb tb' s s')
    (v : Val) (fs : List Frame) (hc : s.ctl = .ret v) (hf : s.stack = .e .typeof :: fs)
    (hv : ∀ a, v = .obj a → a < s.next) (S S' : SSrv) :
    let t := { s with ctl := .ret (.str (typeofStr s v)), stack := fs }
    let t' := { s' with ctl := .ret (.str (typeofStr s v)), stack := fs.map R.frame }
    interpS (step F s).run S = some (t, S) ∧
    interpS (step F s').run S' = some (t', S') ∧ Renamed FR R tb tb' t t' := by
  dsimp only
  have hcs : s'.ctl = .ret (R.val v) := by rw [h.ctl, hc]; rfl
  have hfs : s'.stack = .e .typeof :: fs.map R.frame := by rw [h.stack, hf]; rfl
  have hsupp : AddrSupported s.next (fun Q => fs.map Q.frame) := by
    intro Q P ha hn
    have he := h.closed.stack Q P ha hn
    rw [hf] at he
    exact (List.cons.inj he).2
  refine ⟨?_, ?_, h.control (.ret (.str (typeofStr s v))) fs (by
    dsimp only [AddrSupported]
    intro Q P _ _
    rfl) hsupp⟩
  · simp only [step, hc, stepRet, hf, retStep, retE, retS, St.ret, M.run, M.pure, interpS_pure]
    rw [typeofStr_control]
  · simp only [step, hcs, stepRet, hfs, retStep, retE, retS, St.ret, M.run, M.pure, interpS_pure,
      typeofStr_control, h.typeofStr v hv]

theorem step_numNeg_ref (F : Ffi) (s : St F.S) (i : Nat) (fs : List Frame)
    (hc : s.ctl = .ret (.num (.ref i))) (hf : s.stack = .e (.unary .neg) :: fs)
    (S : SSrv) (e : SymE) (he : S.val (.ref i) = some e) :
    interpS (step F s).run S = some
      ({ s with ctl := .ret (.num (.ref S.tab.length)), stack := fs },
        { S with tab := S.tab ++ [.un .neg e] }) := by
  simp only [step, hc, stepRet, hf, retStep, retE, unaryOp, toNum, M.bind, M.pure,
    numUn, M.un, M.run, retS, St.ret, interpS_un, he, interpS_pure]

/-- Actual machine-level numeric negation allocates corresponding fresh references and
preserves both state and symbolic-server relations. -/
theorem step_numNeg_ref_renamed (F : Ffi) {FR : Ren → F.S → F.S → Prop} {R : Ren}
    {tb tb' : List Event} {s s' : St F.S} (h : Renamed FR R tb tb' s s')
    {θ : Nat → SymE} {S S' : SSrv} (hs : SrvR R θ S S')
    (i : Nat) (fs : List Frame) (hc : s.ctl = .ret (.num (.ref i)))
    (hf : s.stack = .e (.unary .neg) :: fs) (e : SymE) (he : S.val (.ref i) = some e) :
    let t := { s with ctl := .ret (.num (.ref S.tab.length)), stack := fs }
    let t' := { s' with ctl := .ret (.num (.ref S'.tab.length)), stack := fs.map R.frame }
    let T := { S with tab := S.tab ++ [.un .neg e] }
    let T' := { S' with tab := S'.tab ++ [.un .neg (e.subst θ)] }
    interpS (step F s).run S = some (t, T) ∧
    interpS (step F s').run S' = some (t', T') ∧
    Renamed FR R tb tb' t t' ∧ SrvR R θ T T' := by
  dsimp only
  have hcs : s'.ctl = .ret (.num (.ref (R.n i))) := by rw [h.ctl, hc]; rfl
  have hfs : s'.stack = .e (.unary .neg) :: fs.map R.frame := by rw [h.stack, hf]; rfl
  have hsupp : AddrSupported s.next (fun Q => fs.map Q.frame) := by
    intro Q P ha hn
    have ht := h.closed.stack Q P ha hn
    rw [hf] at ht
    exact (List.cons.inj ht).2
  have hctl : AddrSupported s.next (fun Q => Q.ctl (.ret (.num (.ref S.tab.length)))) := by
    intro Q P _ hn
    simp only [Ren.ctl, Ren.val, Ren.num, hn.1]
  have hn : R.n S.tab.length = S'.tab.length := by simpa using hs.fresh 0
  refine ⟨step_numNeg_ref F s i fs hc hf S e he,
    step_numNeg_ref F s' (R.n i) (fs.map R.frame) hcs hfs S' (e.subst θ) (hs.val he), ?_,
    hs.push (.un .neg e)⟩
  have ht := h.control (.ret (.num (.ref S.tab.length))) fs hctl hsupp
  simpa only [Ren.ctl, Ren.val, Ren.num, hn] using ht

end Host.Ts
