import host.sim.steps.Buf

/-! # `TypedArray.prototype.fill` of a whole unframed typed array with a literal

`step_buf_taFill`: the buffer's bytes are rewritten on both sides by the same cells (`fillCells`, under
the map), the typed array returned. -/

namespace Host.Ts.Sim
namespace BufSim
open Host.Ts

theorem fillBlockFold_map {α β : Type} (f : α → β) (block bs : List α) (start count : Nat) :
    (fillBlockFold block bs start count).map f = fillBlockFold (block.map f) (bs.map f) start count := by
  induction count with
  | zero => rfl
  | succ n ih =>
    simp only [fillBlockFold, List.range_succ, List.foldl_append, List.foldl_cons, List.foldl_nil] at ih ⊢
    rw [List.map_append, List.map_append, List.map_take, List.map_drop, ih, List.length_map]

theorem fillBlockFold_supp {A : Nat → Prop} {m : Nat} {block bs : List Byte} (hb : Supp.bytes A m block)
    (hs : Supp.bytes A m bs) (start count : Nat) : Supp.bytes A m (fillBlockFold block bs start count) := by
  induction count with
  | zero => exact hs
  | succ n ih =>
    simp only [fillBlockFold, List.range_succ, List.foldl_append, List.foldl_cons, List.foldl_nil] at ih ⊢
    exact bytes_append (bytes_append (bytes_take ih _) hb) (bytes_drop ih _)

theorem fillCells_map (M : Map) (k : EltK) (c : Cell) (bs : List Byte) (start count : Nat) :
    (fillCells k c bs start count).map M.byte = fillCells k (M.cell c) (bs.map M.byte) start count := by
  rw [fillCells_eq_fold, fillCells_eq_fold, fillBlockFold_map, Map.cellParts]

theorem fillCells_supp {A : Nat → Prop} {m : Nat} {k : EltK} {c : Cell} {bs : List Byte} (hc : Supp.cell A m c)
    (hs : Supp.bytes A m bs) (start count : Nat) : Supp.bytes A m (fillCells k c bs start count) := by
  rw [fillCells_eq_fold]
  exact fillBlockFold_supp (cellParts_supp k hc _ _) hs _ _

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
  {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- A whole fill's continuation after the value's conversion. -/
def fillK (F : Ffi) (s : St F.S) (this : Val) (k : EltK) (b off n : Nat) : Option Cell → Host.Ts.M (St F.S)
  | some c => match s.obj? b with
    | some ⟨.buf bs, p, ps, pr, ex⟩ =>
      retS F (s.setObj b ⟨.buf (fillCells k c bs (off + 0 * k.size) (n - 0)), p, ps, pr, ex⟩) this
    | _ => .fail "fill of native memory"
  | none => typeErr s (chars!"fill value")

theorem bufN_fill_eq (s : St F.S) {ta : Nat} {to : Obj} {k : EltK} {b off n : Nat} (x : F64) (data : List Val)
    (h : typedOf F s (.obj ta) = some (ta, to, k, b, off, n)) :
    bufN F s (.obj ta) [.num (.lit x)] data .taFill =
      Host.Ts.M.bind (toCell k (.num (.lit x))) (fillK F s (.obj ta) k b off n) := by
  simp only [bufN, h]
  funext γ q
  show toCell k (.num (.lit x)) γ _ = toCell k (.num (.lit x)) γ _
  congr 1

/-- **`fill` of a whole unframed typed array with a literal.** -/
theorem _root_.Host.Ts.Sim.step_buf_taFill (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {a : Nat} {o : Obj}
    {data : List Val} (hn : s.next < Sim.bound) (hpT : Present s aTypeErrorProto) {ta : Nat} {x : F64}
    (hc : s.ctl = .call (.obj a) (.obj ta) [.num (.lit x)]) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.buf .taFill) data)) {k : EltK} {b off n : Nat} {to : Obj}
    (hto : s.obj? ta = some to) (htk : to.kind = .typed k b off n) (hfr : K.fr ta = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  have hot : t.obj? (M.a ta) = some (M.obj to) := h.obj? hto hfr
  have e1 : typedOf F s (.obj ta) = some (ta, to, k, b, off, n) := by simp only [typedOf, hto, htk]
  have e2 : typedOf F t (.obj (M.a ta)) = some (M.a ta, M.obj to, k, M.a b, off, n) := by
    have hkt : (M.obj to).kind = .typed k (M.a b) off n := by simp only [Map.obj, htk, Map.kind]
    simp only [typedOf, hot, hkt]
  show MSim _ S C (bufN F s (.obj ta) [.num (.lit x)] data .taFill)
    (bufN F t (.obj (M.a ta)) [.num (.lit x)] (M.vals data) .taFill)
  rw [bufN_fill_eq s x data e1, bufN_fill_eq t x _ e2]
  refine MSim.bind (toCell_sim (A := Present s) h.srv k (.num (.lit x)) trivial (fun i hi => by cases hi)) ?_
  rintro M2 S2 C2 r r' ⟨rfl, g, hsc⟩
  have h2 := h.grow hFR g
  have hI2 := hI_grow hI g.ext
  cases r with
  | none => exact StepPost_grow g (typeErr_sim h2 _ hn hI2 hpT)
  | some c =>
    cases hbo : s.obj? b with
    | none =>
      show MSim _ _ _ (fillK F s (.obj ta) k b off n (some c)) _
      unfold fillK
      rw [hbo]
      exact MSim.fail _ _
    | some bo =>
      obtain ⟨kd, p, ps, pr, ex⟩ := bo
      cases kd with
      | buf bs =>
        have hc2 : Supp.cell (Present s) S2.tab.length c := hsc c rfl
        have hso := h.obj?_supp hbo
        have hbs : Supp.bytes (Present s) S2.tab.length bs := bytes_mono hso.1 g.len
        have hsup := fillCells_supp (k := k) hc2 hbs (off + 0 * k.size) (n - 0)
        obtain ⟨ht, hr⟩ := RelB.setBuf h2 hn hbo _ hsup
        rw [g.ext.a] at ht hr
        have hPb : Present s b := Present.of_get (obj?_iff.1 hbo)
        have hPt : Present s ta := Present.of_get (obj?_iff.1 hto)
        have hv : Supp.val (Present (s.setObj b ⟨.buf (fillCells k c bs (off + 0 * k.size) (n - 0)), p, ps, pr, ex⟩))
            S2.tab.length (.obj ta) := Present.set _ (by have := h.presentBound b hPb; have hb : Sim.bound = 2 ^ 61 := rfl; rw [hb] at hn; omega) hPt
        have hret := sim_ret hr (.obj ta) hv
        show MSim _ _ _ (fillK F s (.obj ta) k b off n (some c)) (fillK F t (.obj (M.a ta)) k (M.a b) off n (some (M2.cell c)))
        unfold fillK
        rw [hbo, ht]
        dsimp only
        rw [← fillCells_map]
        have hval : M2.val (.obj ta) = .obj (M.a ta) := by
          show Val.obj (M2.a ta) = _; rw [g.ext.a]
        rw [hval] at hret
        exact StepPost_grow g hret
      | _ =>
        show MSim _ _ _ (fillK F s (.obj ta) k b off n (some c)) _
        unfold fillK
        rw [hbo]
        exact MSim.fail _ _

end

end BufSim
end Host.Ts.Sim
