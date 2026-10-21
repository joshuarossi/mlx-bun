import host.sim.extract.Tensor
namespace Host.Ts.Sim.ExtractSim
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Extract

/-! # Extracted structures under the map

Relations of extracted source and target structures (`LinearR` … `LoadedR`):
operation and class names equal, tensors `TensorR`, numbers `NatR`, lists and
options elementwise. The relational lemmas take both extractions' success; the
target's model and cache structure is the source's, at the images. -/

def LinearR (P : LoadP) (M : Map) (l l' : Linear) : Prop :=
  l'.operation = l.operation ∧ TensorR P M l.words l'.words ∧ TensorR P M l.scales l'.scales ∧
    ORel (TensorR P M) l.biases l'.biases ∧ NatR P l.bits l'.bits ∧ NatR P l.group l'.group ∧ l'.mode = l.mode

def TrellisR (P : LoadP) (M : Map) (x x' : Trellis) : Prop :=
  TensorR P M x.codes x'.codes ∧ TensorR P M x.scales x'.scales ∧ NatR P x.bits x'.bits

def MlpR (P : LoadP) (M : Map) (m m' : Mlp) : Prop :=
  TensorR P M m.norm m'.norm ∧ TrellisR P M m.gate m'.gate ∧ TrellisR P M m.up m'.up ∧
    TrellisR P M m.down m'.down ∧ m'.gateOperation = m.gateOperation ∧ m'.downOperation = m.downOperation

def NamedR {α β : Type} (R : α → β → Prop) (a : List Char × α) (b : List Char × β) : Prop := b.1 = a.1 ∧ R a.2 b.2

def StageR (P : LoadP) (M : Map) (st st' : Stage) : Prop :=
  st'.attention = st.attention ∧ st'.layerOperation = st.layerOperation ∧
    st'.mixerOperation = st.mixerOperation ∧ TensorR P M st.inputNorm st'.inputNorm ∧
    LRel (NamedR (LinearR P M)) st.linears st'.linears ∧ LRel (NamedR (TensorR P M)) st.tensors st'.tensors ∧
    MlpR P M st.mlp st'.mlp

def ModelR (P : LoadP) (M : Map) (m m' : Model) : Prop :=
  LRel (NamedR (TensorR P M)) m.embedding m'.embedding ∧ TensorR P M m.finalNorm m'.finalNorm ∧
    LinearR P M m.head m'.head ∧ LRel (StageR P M) m.stages m'.stages

/-- Caches: operation class and tensors (offsets are numbers of the iteration, not compared). -/
def CacheR (P : LoadP) (M : Map) (c c' : Cache) : Prop :=
  c'.operation = c.operation ∧ ORel (TensorR P M) c.first c'.first ∧ ORel (TensorR P M) c.second c'.second

/-! ## Lists -/

theorem mapM_rel {α γ δ : Type} {R : γ → δ → Prop} {f : α → Option γ} {g : α → Option δ} :
    ∀ (l : List α) {bs : List γ} {cs : List δ}, (∀ a ∈ l, ∀ b c, f a = some b → g a = some c → R b c) →
      l.mapM f = some bs → l.mapM g = some cs → LRel R bs cs
  | [], bs, cs, _, h1, h2 => by
    simp only [List.mapM_nil, pure, Option.some.injEq] at h1 h2
    subst h1 h2; trivial
  | a :: l, bs, cs, hfg, h1, h2 => by
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at h1 h2
    obtain ⟨b, hb, bs', hbs, rfl⟩ := h1
    obtain ⟨c, hc, cs', hcs, rfl⟩ := h2
    exact ⟨hfg a (List.mem_cons_self ..) b c hb hc,
      mapM_rel l (fun a' ha' => hfg a' (List.mem_cons_of_mem _ ha')) hbs hcs⟩

theorem mapM_map {α α' γ : Type} (φ : α → α') (g : α' → Option γ) :
    ∀ l : List α, (l.map φ).mapM g = l.mapM (g ∘ φ)
  | [] => rfl
  | a :: l => by simp only [List.map_cons, List.mapM_cons, mapM_map φ g l, Function.comp]

theorem mapM_mem {α γ : Type} {f : α → Option γ} : ∀ {l : List α} {bs : List γ}, l.mapM f = some bs →
    ∀ a ∈ l, ∃ b, f a = some b
  | [], _, _, a, ha => nomatch ha
  | x :: l, bs, h, a, ha => by
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at h
    obtain ⟨b, hb, bs', hbs, rfl⟩ := h
    rcases List.mem_cons.1 ha with rfl | ha
    · exact ⟨b, hb⟩
    · exact mapM_mem hbs a ha

section
variable {P : LoadP} {r : List NumV} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St LSt} {S : SSrv} {C : CSrv}

/-- Handles are bigints (`MlxHandle = bigint`): no `#handle` field holds a number. -/
def BigHandles (s : St LSt) : Prop := ∀ v w, privateField s v chars!"handle" = some w → ∀ x, w ≠ .num x

theorem fieldTensor_rel' (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {n : List Char} {T : Tensor} {T' : Tensor}
    (hs : fieldTensor s v n = some T) (ht : fieldTensor t (M.val v) n = some T') : TensorR P M T T' := by
  obtain ⟨T2, h2, hr⟩ := fieldTensor_rel h hv hb hs
  rw [ht] at h2
  cases h2
  exact hr

theorem own_rel (h : Rel LF (LR P r) M ν K s S t C) {v : Val} (hv : SV s S.tab.length v) {n : List Char}
    {w w' : Val} (hs : own s v n = some w) (ht : own t (M.val v) n = some w') : w' = M.val w := by
  rw [own_map h hv, hs] at ht
  exact (Option.some.inj ht).symm

theorem natField_rel (h : Rel LF (LR P r) M ν K s S t C) {v : Val} (hv : SV s S.tab.length v) {n : List Char}
    {k k' : Nat} (hs : (own s v n).bind nat = some k) (ht : (own t (M.val v) n).bind nat = some k') : NatR P k k' := by
  rw [own_map h hv] at ht
  cases ho : own s v n with
  | none => rw [ho] at hs; cases hs
  | some w =>
    rw [ho] at hs ht
    exact nat_rel h hs ht

theorem quantized_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {op : List Char} {l l' : Linear}
    (hs : quantized s v op = some l) (ht : quantized t (M.val v) op = some l') : LinearR P M l l' := by
  unfold quantized at hs ht
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff, pure] at hs ht
  obtain ⟨w, hw, sc, hsc, b, hbb, spec, hspec, bits, hbits, group, hgroup, hrest⟩ := hs
  obtain ⟨w', hw', sc', hsc', b', hbb', spec', hspec', bits', hbits', group', hgroup', hrest'⟩ := ht
  obtain rfl := own_rel h hv hspec hspec'
  have hsv := own_supp h hspec
  obtain ⟨mv, hmv, hl⟩ := hrest
  obtain ⟨mv', hmv', hl'⟩ := hrest'
  obtain rfl := own_rel h hsv hmv hmv'
  cases mv with
    | str mode =>
      simp only [Map.val, Option.some.injEq] at hl hl'
      subst hl hl'
      refine ⟨rfl, fieldTensor_rel' h hb hv hw hw', fieldTensor_rel' h hb hv hsc hsc', ?_,
        natField_rel h hsv (Option.bind_eq_some_iff.2 hbits) (Option.bind_eq_some_iff.2 hbits'),
        natField_rel h hsv (Option.bind_eq_some_iff.2 hgroup) (Option.bind_eq_some_iff.2 hgroup'), rfl⟩
      -- biases
      replace hbb := Option.bind_eq_some_iff.2 hbb
      replace hbb' := Option.bind_eq_some_iff.2 hbb'
      rw [own_map h hv] at hbb'
      cases hob : own s v chars!"_biases" with
      | none => rw [hob] at hbb; cases hbb
      | some bw =>
        rw [hob] at hbb hbb'
        obtain ⟨T2, h2, hr⟩ := optionalTensor_rel h (own_supp h hob) hb hbb
        simp only [Option.map_some, Option.bind_some] at hbb'
        rw [hbb'] at h2
        cases h2
        exact hr
    | _ => simp at hl

theorem projection_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {l l' : Linear}
    (hs : projection s v = some l) (ht : projection t (M.val v) = some l') : LinearR P M l l' := by
  unfold projection at hs ht
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff] at hs ht
  obtain ⟨cls, hcls, q, hq, hl⟩ := hs
  obtain ⟨cls', hcls', q', hq', hl'⟩ := ht
  rw [className_map h hv, hcls] at hcls'
  cases hcls'
  have hqm : ((own t (M.val v) chars!"base").orElse fun _ => own t (M.val v) chars!"linear") =
      ((own s v chars!"base").orElse fun _ => own s v chars!"linear").map M.val := by
    rw [own_map h hv, own_map h hv]
    cases own s v chars!"base" <;> rfl
  rw [hqm, hq] at hq'
  cases hq'
  have hqs : SV s S.tab.length q := by
    cases hb1 : own s v chars!"base" with
    | none =>
      rw [hb1] at hq
      exact own_supp h hq
    | some x =>
      rw [hb1] at hq
      cases hq
      exact own_supp h hb1
  exact quantized_rel h hb hqs hl hl'

theorem trellis_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {x x' : Trellis}
    (hs : trellis s v = some x) (ht : trellis t (M.val v) = some x') : TrellisR P M x x' := by
  unfold trellis at hs ht
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at hs ht
  obtain ⟨c, hc, sc, hsc, spec, hspec, bits, hbits, rfl⟩ := hs
  obtain ⟨c', hc', sc', hsc', spec', hspec', bits', hbits', rfl⟩ := ht
  obtain rfl := own_rel h hv hspec hspec'
  exact ⟨fieldTensor_rel' h hb hv hc hc', fieldTensor_rel' h hb hv hsc hsc',
    natField_rel h (own_supp h hspec) (Option.bind_eq_some_iff.2 hbits) (Option.bind_eq_some_iff.2 hbits')⟩

theorem fieldOf_rel (h : Rel LF (LR P r) M ν K s S t C) {v : Val} (hv : SV s S.tab.length v) {n : List Char}
    {w w' : Val} (hs : own s v n = some w) (ht : own t (M.val v) n = some w') :
    w' = M.val w ∧ SV s S.tab.length w :=
  ⟨own_rel h hv hs ht, own_supp h hs⟩

theorem trellisField_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {n : List Char} {x x' : Trellis}
    (hs : (own s v n).bind (trellis s) = some x) (ht : (own t (M.val v) n).bind (trellis t) = some x') :
    TrellisR P M x x' := by
  rw [own_map h hv] at ht
  cases ho : own s v n with
  | none => rw [ho] at hs; cases hs
  | some w =>
    rw [ho] at hs ht
    exact trellis_rel h hb (own_supp h ho) hs ht

theorem normField_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {n : List Char} {T T' : Tensor}
    (hs : (own s v n).bind (norm s) = some T) (ht : (own t (M.val v) n).bind (norm t) = some T') :
    TensorR P M T T' := by
  rw [own_map h hv] at ht
  cases ho : own s v n with
  | none => rw [ho] at hs; cases hs
  | some w =>
    rw [ho] at hs ht
    exact fieldTensor_rel' h hb (own_supp h ho) hs ht

theorem mlp_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {m m' : Mlp}
    (hs : mlp s v = some m) (ht : mlp t (M.val v) = some m') : MlpR P M m m' := by
  unfold mlp at hs ht
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at hs ht
  obtain ⟨n, hn, op, hop, f, hf, plain, hplain, gu, hgu, dn, hdn, g, hg, u, hu, d, hd, c1, hc1, c2, hc2, rfl⟩ := hs
  obtain ⟨n', hn', op', hop', f', hf', plain', hplain', gu', hgu', dn', hdn', g', hg', u', hu', d', hd', c1', hc1',
    c2', hc2', rfl⟩ := ht
  obtain ⟨rfl, hopv⟩ := fieldOf_rel h hv hop hop'
  rw [privateField_map h hopv, hf] at hf'
  cases hf'
  have hfv := privateField_supp h hf
  rw [closureBinding_map h hfv, hplain] at hplain'
  cases hplain'
  have hpv := closureBinding_supp h hplain
  obtain ⟨rfl, hguv⟩ := fieldOf_rel h hpv hgu hgu'
  obtain ⟨rfl, hdnv⟩ := fieldOf_rel h hpv hdn hdn'
  rw [className_map h hguv, hc1] at hc1'
  rw [className_map h hdnv, hc2] at hc2'
  cases hc1'; cases hc2'
  exact ⟨normField_rel h hb hv (Option.bind_eq_some_iff.2 hn) (Option.bind_eq_some_iff.2 hn'),
    trellisField_rel h hb hguv (Option.bind_eq_some_iff.2 hg) (Option.bind_eq_some_iff.2 hg'),
    trellisField_rel h hb hguv (Option.bind_eq_some_iff.2 hu) (Option.bind_eq_some_iff.2 hu'),
    trellisField_rel h hb hdnv (Option.bind_eq_some_iff.2 hd) (Option.bind_eq_some_iff.2 hd'), rfl, rfl⟩

theorem named_rel {α β : Type} {R : α → β → Prop} {n : List Char} {x : Option α} {y : Option β} {a : List Char × α}
    {b : List Char × β} (hxy : ∀ u w, x = some u → y = some w → R u w)
    (hs : x.map (n, ·) = some a) (ht : y.map (n, ·) = some b) : NamedR R a b := by
  cases hx : x with
  | none => rw [hx] at hs; cases hs
  | some u =>
    cases hy : y with
    | none => rw [hy] at ht; cases ht
    | some w =>
      rw [hx] at hs; rw [hy] at ht
      cases hs; cases ht
      exact ⟨rfl, hxy u w hx hy⟩

theorem projField_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {n : List Char} {l l' : Linear}
    (hs : (own s v n).bind (projection s) = some l) (ht : (own t (M.val v) n).bind (projection t) = some l') :
    LinearR P M l l' := by
  rw [own_map h hv] at ht
  cases ho : own s v n with
  | none => rw [ho] at hs; cases hs
  | some w =>
    rw [ho] at hs ht
    exact projection_rel h hb (own_supp h ho) hs ht

theorem stage_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {st st' : Stage}
    (hs : stage s v = some st) (ht : stage t (M.val v) = some st') : StageR P M st st' := by
  unfold stage at hs ht
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at hs ht
  obtain ⟨mixer, hmix, hrest⟩ := hs
  obtain ⟨mixer', hmix', hrest'⟩ := ht
  obtain ⟨rfl, hmv⟩ := fieldOf_rel h hv hmix hmix'
  have hq : (own t (M.val mixer) chars!"qProj").isSome = (own s mixer chars!"qProj").isSome := by
    rw [own_map h hmv]; cases own s mixer chars!"qProj" <;> rfl
  rw [hq] at hrest'
  generalize (own s mixer chars!"qProj").isSome = attn at hrest hrest'
  obtain ⟨ls, hls, ts, hts, c1, hc1, c2, hc2, n, hn, m, hm, rfl⟩ := hrest
  obtain ⟨ls', hls', ts', hts', c1', hc1', c2', hc2', n', hn', m', hm', rfl⟩ := hrest'
  rw [className_map h hv, hc1] at hc1'
  rw [className_map h hmv, hc2] at hc2'
  cases hc1'; cases hc2'
  have hlin : LRel (NamedR (LinearR P M)) ls ls' :=
    mapM_rel _ (fun nm _ b c hb1 hc => named_rel (fun u w hu hw => projField_rel h hb hmv hu hw) hb1 hc) hls hls'
  refine ⟨rfl, rfl, rfl, normField_rel h hb hv (Option.bind_eq_some_iff.2 hn) (Option.bind_eq_some_iff.2 hn'), hlin, ?_, mlp_rel h hb hv hm hm'⟩
  cases attn with
  | true =>
    exact mapM_rel _ (fun nm _ b c hb1 hc => named_rel (fun u w hu hw => normField_rel h hb hmv hu hw) hb1 hc) hts hts'
  | false =>
    simp only [cond_false, Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at hts hts'
    obtain ⟨ts0, hts0, qk, hqk, q, hq1, k, hk, rfl⟩ := hts
    obtain ⟨ts0', hts0', qk', hqk', q', hq1', k', hk', rfl⟩ := hts'
    obtain ⟨rfl, hqkv⟩ := fieldOf_rel h hmv hqk hqk'
    have h0 : LRel (NamedR (TensorR P M)) ts0 ts0' :=
      mapM_rel _ (fun nm _ b c hb1 hc => named_rel (fun u w hu hw => fieldTensor_rel' h hb hmv hu hw) hb1 hc) hts0 hts0'
    have happ : ∀ (xs : List (List Char × Tensor)) (ys : List (List Char × Tensor)) (zs zs' : List (List Char × Tensor)),
        LRel (NamedR (TensorR P M)) xs ys → LRel (NamedR (TensorR P M)) zs zs' →
        LRel (NamedR (TensorR P M)) (xs ++ zs) (ys ++ zs') := by
      intro xs
      induction xs with
      | nil => intro ys zs zs' hx hz; cases ys with
        | nil => exact hz
        | cons _ _ => cases hx
      | cons x xs ih => intro ys zs zs' hx hz; cases ys with
        | nil => cases hx
        | cons y ys => exact ⟨hx.1, ih ys zs zs' hx.2 hz⟩
    exact happ _ _ _ _ h0 ⟨⟨rfl, fieldTensor_rel' h hb hqkv hq1 hq1'⟩, ⟨rfl, fieldTensor_rel' h hb hqkv hk hk'⟩, trivial⟩

theorem model_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) (hone : ∀ a, privateField s v chars!"one" = some (.obj a) → K.fr a = none)
    {m m' : Model} (hs : model s v = some m) (ht : model t (M.val v) = some m') : ModelR P M m m' := by
  unfold model at hs ht
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at hs ht
  obtain ⟨e, he, emb, hemb, f, hf, lg, hlg, h1, hh1, rh, hrh, one, hone', hd, hhd, sts, hsts, rfl⟩ := hs
  obtain ⟨e', he', emb', hemb', f', hf', lg', hlg', h1', hh1', rh', hrh', one', hone'', hd', hhd', sts', hsts', rfl⟩ := ht
  obtain ⟨rfl, hev⟩ := fieldOf_rel h hv he he'
  obtain ⟨rfl, hlgv⟩ := fieldOf_rel h hv hlg hlg'
  obtain ⟨rfl, hh1v⟩ := fieldOf_rel h hlgv hh1 hh1'
  rw [closureBinding_map h hh1v, hrh] at hrh'
  cases hrh'
  have hrhv := closureBinding_supp h hrh
  replace hone' := Option.bind_eq_some_iff.2 hone'
  replace hone'' := Option.bind_eq_some_iff.2 hone''
  rw [privateField_map h hv] at hone''
  cases hpo : privateField s v chars!"one" with
  | none => rw [hpo] at hone'; cases hone'
  | some ov =>
    rw [hpo] at hone' hone''
    simp only [Option.map_some, Option.bind_some] at hone' hone''
    have hov := privateField_supp h hpo
    rw [elements_map h hov (fun a ha => hone a (by rw [hpo, ha])), hone'] at hone''
    cases hone''
    rw [show M.vals one = one.map M.val from rfl, mapM_map] at hsts'
    have hones := elements_supp h hone'
    refine ⟨mapM_rel _ (fun nm _ b c hb1 hc => named_rel (fun u w hu hw => fieldTensor_rel' h hb hev hu hw) hb1 hc)
      hemb hemb', normField_rel h hb hv (Option.bind_eq_some_iff.2 hf) (Option.bind_eq_some_iff.2 hf'), projection_rel h hb hrhv hhd hhd', ?_⟩
    exact mapM_rel _ (fun x hx b c hb1 hc => stage_rel h hb (hones x hx) hb1 hc) hsts hsts'

/-- The source's cache, without its offset (a template number, symbolic in general). -/
def cacheT (s : St LSt) (v : Val) : Option Cache := do
  let cls ← className s v
  let first ← ((privateField s v chars!"conv").orElse fun _ => own s v chars!"keys").bind (optionalTensor s)
  let second ← ((privateField s v chars!"recurrent").orElse fun _ => own s v chars!"values").bind (optionalTensor s)
  pure ⟨cls, 0, first, second⟩

theorem optField_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {p o : List Char} {T T' : Option Tensor}
    (hs : ((privateField s v p).orElse fun _ => own s v o).bind (optionalTensor s) = some T)
    (ht : ((privateField t (M.val v) p).orElse fun _ => own t (M.val v) o).bind (optionalTensor t) = some T') :
    ORel (TensorR P M) T T' := by
  have e : ((privateField t (M.val v) p).orElse fun _ => own t (M.val v) o) =
      ((privateField s v p).orElse fun _ => own s v o).map M.val := by
    rw [privateField_map h hv, own_map h hv]
    cases privateField s v p <;> rfl
  rw [e] at ht
  cases hx : ((privateField s v p).orElse fun _ => own s v o) with
  | none => rw [hx] at hs; cases hs
  | some w =>
    rw [hx] at hs ht
    have hw : SV s S.tab.length w := by
      cases hp : privateField s v p with
      | none => rw [hp] at hx; exact own_supp h hx
      | some x => rw [hp] at hx; cases hx; exact privateField_supp h hp
    obtain ⟨T2, h2, hr⟩ := optionalTensor_rel h hw hb hs
    simp only [Option.map_some, Option.bind_some] at ht
    rw [ht] at h2
    cases h2
    exact hr

theorem cache_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {v : Val}
    (hv : SV s S.tab.length v) {c c' : Cache}
    (hs : cacheT s v = some c) (ht : cache t (M.val v) = some c') : CacheR P M c c' := by
  unfold cacheT at hs
  unfold cache at ht
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at hs ht
  obtain ⟨cls, hcls, f, hf, sc, hsc, rfl⟩ := hs
  obtain ⟨cls', hcls', off', _, f', hf', sc', hsc', rfl⟩ := ht
  rw [className_map h hv, hcls] at hcls'
  cases hcls'
  exact ⟨rfl, optField_rel h hb hv (Option.bind_eq_some_iff.2 hf) (Option.bind_eq_some_iff.2 hf'),
    optField_rel h hb hv (Option.bind_eq_some_iff.2 hsc) (Option.bind_eq_some_iff.2 hsc')⟩

def LoadedR (P : LoadP) (M : Map) (l l' : Loaded) : Prop :=
  ModelR P M l.model l'.model ∧ LRel (CacheR P M) l.cache l'.cache

/-- The source's loaded objects, with caches by `cacheT`. -/
def loadedT (s : St LSt) (env : Env) : Option Loaded := do
  let m ← (bindingOf s env chars!"model").bind (model s)
  let cs ← ((bindingOf s env chars!"cache").bind (elements s)).bind (List.mapM (cacheT s))
  pure ⟨m, cs⟩

/-- **The target's loaded objects are the source's under the map.** -/
theorem loaded_rel (h : Rel LF (LR P r) M ν K s S t C) (hb : BigHandles s) {env : Env}
    (he : Supp.env (Present s) S.tab.length env)
    (hone : ∀ mv a, bindingOf s env chars!"model" = some mv → privateField s mv chars!"one" = some (.obj a) →
      K.fr a = none)
    (hcache : ∀ a, bindingOf s env chars!"cache" = some (.obj a) → K.fr a = none)
    {l l' : Loaded} (hs : loadedT s env = some l) (ht : loaded t (M.env env) = some l') : LoadedR P M l l' := by
  unfold loadedT at hs
  unfold loaded at ht
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at hs ht
  obtain ⟨m, hm, cs, hcs, rfl⟩ := hs
  obtain ⟨m', hm', cs', hcs', rfl⟩ := ht
  replace hm := Option.bind_eq_some_iff.2 hm
  replace hm' := Option.bind_eq_some_iff.2 hm'
  obtain ⟨es0, hes0, hmap⟩ := hcs
  obtain ⟨es0', hes0', hmap'⟩ := hcs'
  have hcs := Option.bind_eq_some_iff.2 ⟨es0, Option.bind_eq_some_iff.2 hes0, hmap⟩
  have hcs' := Option.bind_eq_some_iff.2 ⟨es0', Option.bind_eq_some_iff.2 hes0', hmap'⟩
  rw [bindingOf_map h he] at hm' hcs'
  cases hmb : bindingOf s env chars!"model" with
  | none => rw [hmb] at hm; cases hm
  | some mv =>
    rw [hmb] at hm hm'
    simp only [Option.map_some, Option.bind_some] at hm hm'
    refine ⟨model_rel h hb (bindingOf_supp h hmb) (fun a ha => hone mv a hmb ha) hm hm', ?_⟩
    cases hcb : bindingOf s env chars!"cache" with
    | none => rw [hcb] at hcs; cases hcs
    | some cv =>
      rw [hcb] at hcs hcs'
      simp only [Option.map_some, Option.bind_some] at hcs hcs'
      have hcv := bindingOf_supp h hcb
      rw [elements_map h hcv (fun a ha => hcache a (by rw [hcb, ha]))] at hcs'
      cases hel : elements s cv with
      | none => rw [hel] at hcs; cases hcs
      | some es =>
        rw [hel] at hcs hcs'
        simp only [Option.map_some, Option.bind_some] at hcs hcs'
        rw [show M.vals es = es.map M.val from rfl, mapM_map] at hcs'
        have hes := elements_supp h hel
        exact mapM_rel _ (fun x hx b c hb1 hc => cache_rel h hb (hes x hx) hb1 hc) hcs hcs'

end
end Host.Ts.Sim.ExtractSim
