import metal.Assemble

namespace Metal.Assemble
open Host.Mlx

/-! # The assembled text depends on input shapes only through MLX's classification

`write_signature` and `kernel_name` (metal_kernel.cpp:95-136, 313-321) read of an input array its name,
its dtype, whether it is a scalar (rank 0: `&` and suffix `s`) and whether it has fewer than
`maxConstantArraySize` elements (the `constant` address space and suffix `c`); the dimensions themselves
never reach the text (a kernel reads them at run time from its `<name>_shape` buffer). So two input lists
with the same names, dtypes and classification assemble to the same text (`assemble_cls`); in particular
any shapes of at least 8 elements give the text of any other such shapes (`assemble_device`). -/

/-- What the assembly reads of an input: name, dtype, scalar or not, constant or device. -/
def Input.cls (i : Input) : List Char × Dtype × Bool × Bool :=
  (i.name, i.dtype, i.shape.isEmpty, decide (i.size < maxConstantArraySize))

theorem inputSuffix_cls {a b : Input} (h : a.cls = b.cls) : inputSuffix a = inputSuffix b := by
  simp only [Input.cls, Prod.mk.injEq, decide_eq_decide] at h
  obtain ⟨-, hd, he, hs⟩ := h
  unfold inputSuffix
  rw [hd, he]
  by_cases ha : a.size < maxConstantArraySize
  · rw [ite_eq_left ha, ite_eq_left (hs.mp ha)]
  · rw [ite_eq_right ha, ite_eq_right (fun hb => ha (hs.mpr hb))]

theorem inputLines_cls (source : List Char) :
    ∀ (as bs : List Input), as.map Input.cls = bs.map Input.cls → ∀ index,
      inputLines source as index = inputLines source bs index
  | [], [], _, _ => rfl
  | [], _ :: _, h, _ => by simp at h
  | _ :: _, [], h, _ => by simp at h
  | a :: as, b :: bs, h, index => by
    simp only [List.map_cons, List.cons.injEq] at h
    obtain ⟨hab, hrest⟩ := h
    have h' := hab
    simp only [Input.cls, Prod.mk.injEq, decide_eq_decide] at h'
    obtain ⟨hn, hd, he, hs⟩ := h'
    have hloc : (if a.size < maxConstantArraySize then chars!"constant" else chars!"device") =
        (if b.size < maxConstantArraySize then chars!"constant" else chars!"device") := by
      by_cases ha : a.size < maxConstantArraySize
      · rw [ite_eq_left ha, ite_eq_left (hs.mp ha)]
      · rw [ite_eq_right ha, ite_eq_right (fun hb => ha (hs.mpr hb))]
    simp only [inputLines]
    rw [hd, hn, he, hloc]
    have ih := inputLines_cls source as bs hrest
    split <;> simp only [ih]

theorem kernelName_cls (name : List Char) {as bs : List Input} (h : as.map Input.cls = bs.map Input.cls)
    (outputDtypes : List Dtype) (args : List TemplateArg) :
    kernelName name as outputDtypes args = kernelName name bs outputDtypes args := by
  have hm : as.mapM inputSuffix = bs.mapM inputSuffix := by
    induction as generalizing bs with
    | nil => cases bs with
      | nil => rfl
      | cons _ _ => simp at h
    | cons a as ih => cases bs with
      | nil => simp at h
      | cons b bs =>
        simp only [List.map_cons, List.cons.injEq] at h
        simp only [List.mapM_cons, inputSuffix_cls h.1, ih h.2]
  unfold kernelName
  rw [hm]

theorem signature_cls (kn source : List Char) {as bs : List Input} (h : as.map Input.cls = bs.map Input.cls)
    (outputNames : List (List Char)) (outputDtypes : List Dtype) (args : List TemplateArg) (atomic : Bool) :
    signature kn source as outputNames outputDtypes args atomic = signature kn source bs outputNames outputDtypes args atomic := by
  have hl : as.length = bs.length := by simpa using congrArg List.length h
  unfold signature
  rw [inputLines_cls source as bs h 0, hl]

/-- **Shape independence.** Inputs with the same names, dtypes and classification (scalar or not, constant or
device) assemble to the same text. -/
theorem assemble_cls (name : List Char) {as bs : List Input} (h : as.map Input.cls = bs.map Input.cls)
    (outputNames : List (List Char)) (outputDtypes : List Dtype) (source header : List Char)
    (args : List TemplateArg) (atomic : Bool) :
    assemble name as outputNames outputDtypes source header args atomic =
      assemble name bs outputNames outputDtypes source header args atomic := by
  unfold assemble
  simp only [kernelName_cls name h, signature_cls _ source h]

/-- An input of at least `maxConstantArraySize` elements: a device array (and not a scalar). -/
theorem cls_device {a b : Input} (hn : a.name = b.name) (hd : a.dtype = b.dtype)
    (ha : maxConstantArraySize ≤ a.size) (hb : maxConstantArraySize ≤ b.size) : a.cls = b.cls := by
  have hea : a.shape.isEmpty = false := by
    cases hs : a.shape with
    | nil => simp [Input.size, hs, maxConstantArraySize] at ha
    | cons _ _ => rfl
  have heb : b.shape.isEmpty = false := by
    cases hs : b.shape with
    | nil => simp [Input.size, hs, maxConstantArraySize] at hb
    | cons _ _ => rfl
  simp only [Input.cls, hn, hd, hea, heb, decide_eq_false (Nat.not_lt.mpr ha), decide_eq_false (Nat.not_lt.mpr hb)]

end Metal.Assemble
