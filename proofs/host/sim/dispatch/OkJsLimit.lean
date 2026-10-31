import host.sim.dispatch.JsImageSim
import host.sim.steps.BigJsLimit
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

section
variable {F : Ffi} (P : JSP F) (limit D0 : Nat)

def jsElemLimitB (s : St F.S) : Val → Bool
  | .big i => match jsPtrOf i with
    | some (b, _) => presB s b && Nat.blt (s.next + D0) limit
    | none => false
  | _ => true

def ctorElemsLimitB (s : St F.S) (S : SSrv) (k : EltK) (v : Val) : Bool :=
  match interpS (elemsOf F s v).run S with
  | some (some vs, _) => allB (fun x => convB P s k x || jsElemLimitB limit D0 s x) vs
  | _ => true

def typedJsLimitB (s : St F.S) (S : SSrv) : Bool :=
  Nat.blt s.next nextMax && match s.ctl with
  | .construct (.obj a) args _ => match s.obj? a with
    | some o => match o.kind with
      | .fn (.native (.buf .typedCtor) [.num (.lit c), .num (.lit p)]) => match F64.toIndex? c, F64.toIndex? p with
        | some ci, some proto => Nat.blt proto aFirst && presB s aArrayBufferProto && presB s proto &&
            presB s aTypeErrorProto && elemsB P s S.tab.length (arg args 0) &&
            (match arg args 0 with
              | .obj b => match s.obj? b with
                | some ob => match ob.kind with
                  | .array _ => ctorElemsLimitB P limit D0 s S (eltOfCode ci) (arg args 0)
                  | _ => false
                | none => false
              | _ => false)
        | _, _ => false
      | _ => false
    | none => false
  | _ => false

/-- A layer over the unchanged acceptance, permitting larger target pointer images. -/
def okJSJLimit (okBack : F.S → Arg → Bool) (s : St F.S) (S : SSrv) : Bool :=
  okJSJImage P D0 okBack s S || typedJsLimitB P limit D0 s S
end

section
variable {F : Ffi} {P : JSP F} {limit D0 D1 : Nat} {s : St F.S} {S : SSrv}

theorem jsElemLimitB_of_room (hroom : s.next + D1 < limit) {v : Val}
    (h : jsElemB D0 s v = true) : jsElemLimitB limit D1 s v = true := by
  cases v <;> try rfl
  rename_i i
  simp only [jsElemB] at h
  cases hp : jsPtrOf i with
  | none => rw [hp] at h; cases h
  | some q =>
    rcases q with ⟨b, off⟩
    simp only [hp, Bool.and_eq_true] at h
    simp only [jsElemLimitB, hp, h.1, Bool.true_and, Nat.blt_eq]
    exact hroom

theorem ctorElemsLimitB_of (hElem : ∀ v, jsElemB D0 s v = true → jsElemLimitB limit D1 s v = true) {k : EltK} {v : Val}
    (h : ctorElemsJB P D0 s S k v = true) : ctorElemsLimitB P limit D1 s S k v = true := by
  unfold ctorElemsJB at h
  unfold ctorElemsLimitB
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

theorem ctorElemsLimitB_of_room (hroom : s.next + D1 < limit) {k : EltK} {v : Val}
    (h : ctorElemsJB P D0 s S k v = true) : ctorElemsLimitB P limit D1 s S k v = true :=
  ctorElemsLimitB_of (fun _ => jsElemLimitB_of_room hroom) h

theorem typedJsLimitB_of (hElem : ∀ v, jsElemB D0 s v = true → jsElemLimitB limit D1 s v = true)
    (h : typedJsB P D0 s S = true) : typedJsLimitB P limit D1 s S = true := by
  obtain ⟨a, args, nt, o, c, p, ci, proto, b, ob, es, hc, ho, hk, hci, hpi,
    hn, h1, h2, h3, h4, h5, hb, hob, hes, he⟩ := typedJsB_spec h
  have hi := ctorElemsLimitB_of hElem he
  simp only [hb] at hi
  have hp : Nat.blt proto aFirst = true := by rw [Nat.blt_eq]; exact h1
  have hp14 : presB s aArrayBufferProto = true := h2
  have hpp : presB s proto = true := h3
  have hpT : presB s aTypeErrorProto = true := h4
  unfold typedJsLimitB
  simp only [hc, ho, hk, hci, hpi, hb, hob, hes, hn, hp, hp14, hpp, hpT,
    show elemsB P s S.tab.length (.obj b) = true by simpa only [hb] using h5, hi, Bool.and_self]

theorem typedJsLimitB_of_room (hroom : s.next + D1 < limit)
    (h : typedJsB P D0 s S = true) : typedJsLimitB P limit D1 s S = true :=
  typedJsLimitB_of (fun _ => jsElemLimitB_of_room hroom) h


/-- Existing fixed-limit image acceptance is an unchanged branch. -/
theorem okJSJLimit_of_image {okBack : F.S → Arg → Bool}
    (h : okJSJImage P D0 okBack s S = true) : okJSJLimit P limit D0 okBack s S = true := by
  simp only [okJSJLimit, h, Bool.true_or]

/-- Every old accepted state remains accepted at the same allowance. -/
theorem okJSJLimit_of_old {okBack : F.S → Arg → Bool}
    (h : okJSJ P okBack D0 s S = true) : okJSJLimit P limit D0 okBack s S = true :=
  okJSJLimit_of_image (okJSJImage_of_old h)

/-- Transfer the old acceptance using an implication for its JS pointer elements. -/
theorem okJSJLimit_of_elements {okBack : F.S → Arg → Bool}
    (hElem : ∀ v, jsElemB D0 s v = true → jsElemLimitB limit D1 s v = true)
    (h : okJSJ P okBack D0 s S = true) : okJSJLimit P limit D1 okBack s S = true := by
  unfold okJSJ at h
  simp only [okJSJLimit, Bool.or_eq_true] at h ⊢
  rcases h with (h | h) | h
  · exact .inl (okJSJImage_of_old (okJSK_J h))
  · exact .inl (okJSJImage_of_old (by simp only [okJSJ, h, Bool.or_true, Bool.true_or]))
  · exact .inr (typedJsLimitB_of hElem h)

/-- Room at the new allowance suffices to transfer any old accepted state. -/
theorem okJSJLimit_of_room {okBack : F.S → Arg → Bool} (hroom : s.next + D1 < limit)
    (h : okJSJ P okBack D0 s S = true) : okJSJLimit P limit D1 okBack s S = true :=
  okJSJLimit_of_elements (fun _ => jsElemLimitB_of_room hroom) h

/-- Uniform allowance transfer, requiring no bound on intermediate allocator counters. -/
theorem okJSJLimit_of_allowance {okBack : F.S → Arg → Bool}
    (hD : D1 + lim29 ≤ D0 + limit)
    (h : okJSJ P okBack D0 s S = true) : okJSJLimit P limit D1 okBack s S = true := by
  apply okJSJLimit_of_elements ?_ h
  intro v hv
  cases v <;> try rfl
  rename_i i
  cases hp : jsPtrOf i with
  | none => simp only [jsElemB, hp] at hv; cases hv
  | some q =>
    rcases q with ⟨b, off⟩
    have hv' := hv
    simp only [jsElemB, hp, Bool.and_eq_true, Nat.blt_eq] at hv'
    apply jsElemLimitB_of_room (D0 := D0) _ hv
    have hroom := hv'.2
    omega

/-- The maximum signed-cell target limit supplies the requested additional allowance. -/
theorem okJSJLimit_signed_of_allowance {okBack : F.S → Arg → Bool}
    (hD : D1 ≤ D0 + 1593835520)
    (h : okJSJ P okBack D0 s S = true) : okJSJLimit P jsSignedLimit D1 okBack s S = true := by
  apply okJSJLimit_of_allowance _ h
  simp only [lim29, jsSignedLimit]
  omega
end
end Host.Ts.Sim.Disp
