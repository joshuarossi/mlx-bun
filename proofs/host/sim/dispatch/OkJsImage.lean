import host.sim.dispatch.OkJs
import host.sim.steps.BigJsImage
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

/-- Target address allowance for the larger-image conversion theorem. -/
def lim30 : Nat := 1073741824

section
variable {F : Ffi} (P : JSP F) (D0 : Nat)

def jsElemImageB (s : St F.S) : Val → Bool
  | .big i => match jsPtrOf i with
    | some (b, _) => presB s b && Nat.blt (s.next + D0) lim30
    | none => false
  | _ => true

def ctorElemsImageB (s : St F.S) (S : SSrv) (k : EltK) (v : Val) : Bool :=
  match interpS (elemsOf F s v).run S with
  | some (some vs, _) => allB (fun x => convB P s k x || jsElemImageB D0 s x) vs
  | _ => true

def typedJsImageB (s : St F.S) (S : SSrv) : Bool :=
  Nat.blt s.next nextMax && match s.ctl with
  | .construct (.obj a) args _ => match s.obj? a with
    | some o => match o.kind with
      | .fn (.native (.buf .typedCtor) [.num (.lit c), .num (.lit p)]) => match F64.toIndex? c, F64.toIndex? p with
        | some ci, some proto => Nat.blt proto aFirst && presB s aArrayBufferProto && presB s proto &&
            presB s aTypeErrorProto && elemsB P s S.tab.length (arg args 0) &&
            (match arg args 0 with
              | .obj b => match s.obj? b with
                | some ob => match ob.kind with
                  | .array _ => ctorElemsImageB P D0 s S (eltOfCode ci) (arg args 0)
                  | _ => false
                | none => false
              | _ => false)
        | _, _ => false
      | _ => false
    | none => false
  | _ => false

/-- A layer over the unchanged acceptance, permitting larger target pointer images. -/
def okJSJImage (okBack : F.S → Arg → Bool) (s : St F.S) (S : SSrv) : Bool :=
  okJSJ P okBack D0 s S || typedJsImageB P D0 s S
end

section
variable {F : Ffi} {P : JSP F} {D0 D1 : Nat} {s : St F.S} {S : SSrv}

theorem jsElemImageB_of_room (hroom : s.next + D1 < lim30) {v : Val}
    (h : jsElemB D0 s v = true) : jsElemImageB D1 s v = true := by
  cases v <;> try rfl
  rename_i i
  simp only [jsElemB] at h
  cases hp : jsPtrOf i with
  | none => rw [hp] at h; cases h
  | some q =>
    rcases q with ⟨b, off⟩
    simp only [hp, Bool.and_eq_true] at h
    simp only [jsElemImageB, hp, h.1, Bool.true_and, Nat.blt_eq]
    exact hroom

theorem ctorElemsImageB_of (hElem : ∀ v, jsElemB D0 s v = true → jsElemImageB D1 s v = true) {k : EltK} {v : Val}
    (h : ctorElemsJB P D0 s S k v = true) : ctorElemsImageB P D1 s S k v = true := by
  unfold ctorElemsJB at h
  unfold ctorElemsImageB
  cases hr : interpS (elemsOf F s v).run S with
  | none => rfl
  | some pair =>
    rcases pair with ⟨vs, S1⟩
    cases vs with
    | none => rfl
    | some vs =>
      simp only [hr] at h ⊢
      clear hr
      induction vs with
      | nil => rfl
      | cons v vs ih =>
        simp only [allB, Bool.and_eq_true, Bool.or_eq_true] at h ⊢
        refine ⟨?_, ih h.2⟩
        rcases h.1 with hc | hj
        · exact .inl hc
        · exact .inr (hElem _ hj)

theorem ctorElemsImageB_of_room (hroom : s.next + D1 < lim30) {k : EltK} {v : Val}
    (h : ctorElemsJB P D0 s S k v = true) : ctorElemsImageB P D1 s S k v = true :=
  ctorElemsImageB_of (fun _ => jsElemImageB_of_room hroom) h

theorem typedJsImageB_of (hElem : ∀ v, jsElemB D0 s v = true → jsElemImageB D1 s v = true)
    (h : typedJsB P D0 s S = true) : typedJsImageB P D1 s S = true := by
  obtain ⟨a, args, nt, o, c, p, ci, proto, b, ob, es, hc, ho, hk, hci, hpi,
    hn, h1, h2, h3, h4, h5, hb, hob, hes, he⟩ := typedJsB_spec h
  have hi := ctorElemsImageB_of hElem he
  simp only [hb] at hi
  have hp : Nat.blt proto aFirst = true := by rw [Nat.blt_eq]; exact h1
  have hp14 : presB s aArrayBufferProto = true := h2
  have hpp : presB s proto = true := h3
  have hpT : presB s aTypeErrorProto = true := h4
  unfold typedJsImageB
  simp only [hc, ho, hk, hci, hpi, hb, hob, hes, hn, hp, hp14, hpp, hpT,
    show elemsB P s S.tab.length (.obj b) = true by simpa only [hb] using h5, hi, Bool.and_self]

theorem typedJsImageB_of_room (hroom : s.next + D1 < lim30)
    (h : typedJsB P D0 s S = true) : typedJsImageB P D1 s S = true :=
  typedJsImageB_of (fun _ => jsElemImageB_of_room hroom) h

/-- Old checked states transfer to a different allowance when the larger-image room holds. -/
theorem okJSJImage_of_room {okBack : F.S → Arg → Bool} (hroom : s.next + D1 < lim30)
    (h : okJSJ P okBack D0 s S = true) : okJSJImage P D1 okBack s S = true := by
  unfold okJSJ at h
  simp only [okJSJImage, Bool.or_eq_true] at h ⊢
  rcases h with (h | h) | h
  · exact .inl (okJSK_J h)
  · exact .inl (by simp only [okJSJ, h, Bool.or_true, Bool.true_or])
  · exact .inr (typedJsImageB_of_room hroom h)

/-- Every state accepted by the base layer remains accepted. -/
theorem okJSJImage_of_old {okBack : F.S → Arg → Bool}
    (h : okJSJ P okBack D0 s S = true) : okJSJImage P D0 okBack s S = true := by
  simp only [okJSJImage, h, Bool.true_or]

/-- An allowance increase of at most `2^29` transfers uniformly, using the old element's room check. -/
theorem okJSJImage_of_allowance {okBack : F.S → Arg → Bool} (hD : D1 ≤ D0 + lim29)
    (h : okJSJ P okBack D0 s S = true) : okJSJImage P D1 okBack s S = true := by
  have hElem : ∀ v, jsElemB D0 s v = true → jsElemImageB D1 s v = true := by
    intro v hv
    cases v <;> try rfl
    rename_i i
    cases hp : jsPtrOf i with
    | none => simp only [jsElemB, hp] at hv; cases hv
    | some q =>
      rcases q with ⟨b, off⟩
      have hv' := hv
      simp only [jsElemB, hp, Bool.and_eq_true, Nat.blt_eq] at hv'
      apply jsElemImageB_of_room (D0 := D0) _ hv
      have hroom := hv'.2
      simp only [lim29, lim30] at hD hroom ⊢
      omega
  unfold okJSJ at h
  simp only [okJSJImage, Bool.or_eq_true] at h ⊢
  rcases h with (h | h) | h
  · exact .inl (okJSK_J h)
  · exact .inl (by simp only [okJSJ, h, Bool.or_true, Bool.true_or])
  · exact .inr (typedJsImageB_of hElem h)
end

end Host.Ts.Sim.Disp
