import host.sim.footprint.HeapBasic

namespace Host.Ts.Sim.HeapFoot
open Host.Ts Host.Ts.Sim Conv BufSim

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
  {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx} {S : SSrv} {C : CSrv}

/-- Successful JS buffer writes have the caller footprint, including repeated writes. -/
theorem applyWrites_foot : ∀ (ws : List (Nat × Nat × List Byte)) {s t u : St F.S},
    RelB F FR W stk M ν K s S t C → s.next < Sim.bound →
    (∀ w ∈ ws, Supp.bytes (fun _ => True) S.tab.length w.2.2) →
    applyWrites F s ws = some u →
    ∃ v, applyWrites F t (ws.map M.write) = some v ∧ RelB F FR W stk M ν K u S v C ∧
      HeapStepFoot M s t u v ∧ u.next = s.next ∧ v.next = t.next
  | [], s, t, u, h, _, _, hw => by
    cases hw
    exact ⟨t, rfl, h, HeapStepFoot.sameHeap rfl rfl rfl, rfl, rfl⟩
  | (b, off, bytes) :: ws, s, t, u, h, hn, hsupp, hw => by
    simp only [applyWrites] at hw
    cases ho : s.obj? b with
    | none => rw [ho] at hw; cases hw
    | some o =>
      rw [ho] at hw
      obtain ⟨kd, pr, ps, pv, e⟩ := o
      cases kd with
      | buf bs =>
        simp only at hw
        have hb := Present.of_get (obj?_iff.1 ho)
        have hso := h.obj?_supp ho
        have hbytes : Supp.bytes (Present s) S.tab.length bytes :=
          bytesA (hsupp (b, off, bytes) (List.mem_cons_self ..))
        obtain ⟨ht, hr⟩ := RelB.setBuf h hn ho (bs.take off ++ bytes ++ bs.drop (off + len bytes))
          (bytes_append (bytes_append (bytes_take hso.1 _) hbytes) (bytes_drop hso.1 _))
        obtain ⟨v, hv, hr', hf, hsn, htn⟩ := applyWrites_foot ws hr hn
          (fun w hw => hsupp w (List.mem_cons_of_mem _ hw)) hw
        have hs64 : b < 2 ^ 64 := by
          have := h.presentBound b hb
          have : Sim.bound = 2 ^ 61 := rfl
          omega
        have ht64 : M.a b < 2 ^ 64 := by
          have := h.bound b hb
          have := h.tnext hn
          omega
        let o1 : Obj := ⟨.buf (bs.take off ++ bytes ++ bs.drop (off + len bytes)), pr, ps, pv, e⟩
        have hf0 := HeapStepFoot.write (M := M) (t := t) (o := .obj o1) (o' := .obj (M.obj o1)) hb hs64 ht64
        refine ⟨v, ?_, hr', hf0.trans hf h.next (Nat.le_refl _), hsn, htn⟩
        simp only [List.map_cons, Map.write, applyWrites, ht, len_map]
        simp only [List.map_append, List.map_take, List.map_drop] at hv
        exact hv
      | _ => cases hw

/-- FFI completion: actual buffer writes, the event, and a normal result or JS callback. -/
theorem ffiDone_foot {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
    (hn : s.next < Sim.bound) {name : Name} {args : List Arg}
    (has : ∀ a ∈ args, Supp.arg (Present s) S.tab.length a)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase))
    {r r' : Option (F.S × Ret × List (Nat × Nat × List Byte))}
    (hr : CallR FR M S.tab.length r r') (hres : ResOK F K s S.tab.length r) :
    MSim (Post F FR W stk M ν K S C s t) S C
      (ffiDone F s name args r) (ffiDone F t name (args.map M.arg) r') := by
  cases r with
  | none => exact MSim.fail _ _
  | some p =>
    obtain ⟨x, ret, ws⟩ := p
    cases r' with
    | none => exact hr.elim
    | some p' =>
      obtain ⟨y, ret', ws'⟩ := p'
      obtain ⟨hxy, rfl, rfl⟩ := hr
      obtain ⟨hret, hws, hcb⟩ := hres
      have h1 := h.setFfi x y hxy
      simp only [ffiDone]
      cases hw : applyWrites F (s.setFfi x) ws with
      | none => exact MSim.fail _ _
      | some s2 =>
        obtain ⟨t2, ht2, hr2, hf, -, -⟩ := applyWrites_foot ws h1 hn hws hw
        rw [ht2]
        obtain ⟨t2', ht2', -, -, hp2⟩ := applyWrites_rel ws h1 hn hws hw
        have et : t2' = t2 := Option.some.inj (ht2'.symm.trans ht2)
        subst t2'
        have hP : ∀ a, Present s a → Present s2 a := fun a ha => (hp2 a).2 ha
        have he : Supp.event (Present s2) S.tab.length ⟨name, args, ret⟩ :=
          ⟨fun a ha => Supp.arg_mono hP (Nat.le_refl _) (has a ha),
            Supp.ret_mono hP (Nat.le_refl _) hret⟩
        have h3 := hr2.event ⟨name, args, ret⟩ he
        cases ret with
        | callback f cargs =>
          have hm := ffiCallback_sim (name := name) h3 (Supp.ret_mono hP (Nat.le_refl _) hret)
            (fun hge hp => hcbr f hge ((hp2 _).1 hp)) (hcb s2 hw)
          apply (hm.withRuns (ffiCallback_lawful _ _ _ _ _) (ffiCallback_lawful _ _ _ _ _)).mono
          rintro M' S' C' u v ⟨hp, hsrun, htrun⟩
          refine ⟨hp, congr hf ⟨rfl, rfl⟩ ⟨rfl, rfl⟩ ?_ ?_⟩
          · exact (ffiCallback_same F
              (s2.setTrace (⟨name, args, .callback f cargs⟩ :: s2.trace)) name f cargs).1 S u S' hsrun
          · exact (ffiCallback_same F
              (t2.setTrace (M.event ⟨name, args, .callback f cargs⟩ :: t2.trace))
              name (M.region f) (cargs.map M.arg)).2 C v C' htrun
        | _ =>
          exact MSim.pure ⟨⟨Grow.refl h3.srv,
            h3.ret _ (retVal_supp (Supp.ret_mono hP (Nat.le_refl _) hret))⟩,
            congr hf ⟨rfl, rfl⟩ ⟨rfl, rfl⟩ ⟨rfl, rfl⟩ ⟨rfl, rfl⟩⟩

end
end Host.Ts.Sim.HeapFoot
