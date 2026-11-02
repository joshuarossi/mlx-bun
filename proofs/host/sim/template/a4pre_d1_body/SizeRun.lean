import host.sim.template.a4pre_d1_body.SizeLift
import host.sim.Loop
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodySize
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Disp Host.Ts.Sim.BufSim

-- The existing B-size tail consists of two actual pure machine transitions.
theorem tailRun {F : Ffi} {u : St F.S} {C : CSrv} {ret : Ret} {w : Val}
    {nf : Nat} {thisN : Val} {env : Env} {fs : List Frame} {o : Obj} {data : List Val}
    (hc : u.ctl = .ret (retVal ret)) (hs : u.stack = .c (.args 0 (.obj nf) thisN [] [] env) :: fs)
    (ho : u.obj? nf = some o) (hk : o.kind = .fn (.native (.num .number) data))
    (hw : numRet ret = some w) :
    runC F 2 u C = some (({ u with stack := fs }.ret w), C) := by
  have e1 : step F u = Host.Ts.M.pure ({ u with stack := fs }.go (.call (.obj nf) thisN [retVal ret])) := by
    simp only [step, hc, stepRet, hs]
    rfl
  have e2 : step F ({ u with stack := fs }.go (.call (.obj nf) thisN [retVal ret])) =
      Host.Ts.M.pure ({ u with stack := fs }.ret w) := by
    have ht := size_tail (F := F) hc hs ho hk hw
    rw [e1] at ht
    exact ht
  have h1 : runC F 1 u C =
      some (({ u with stack := fs }.go (.call (.obj nf) thisN [retVal ret])), C) :=
    runC_one (by rw [hc]; rfl) (by rw [e1]; rfl)
  have h2 : runC F 1 ({ u with stack := fs }.go (.call (.obj nf) thisN [retVal ret])) C =
      some (({ u with stack := fs }.ret w), C) :=
    runC_one rfl (by rw [e2]; rfl)
  exact runC_trans h1 h2

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
  {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Host.Ts.Sim.Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool}
  {okBack : F.S → Arg → Bool}

theorem bridgeRun (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack) (hL : FfiLawful F)
    {fsym ta nf : Nat} {this thisN : Val} {args : List Val} {fo oa no : Obj} {name rt : Name} {tys : List Val}
    {ndata : List Val} {env : Env} {fs : List Frame} {Pre : (Nat → F64) → SSrv → F.S → List Arg → Prop}
    (hc : s.ctl = .call (.obj fsym) this args) (hfo : s.obj? fsym = some fo)
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str name, .obj ta, .str rt]))
    (hta : s.obj? ta = some oa) (htk : oa.kind = .array tys) (hfr : K.fr ta = none)
    (hst : s.stack = .c (.args 0 (.obj nf) thisN [] [] env) :: fs) (hno : s.obj? nf = some no)
    (hnk : no.kind = .fn (.native (.num .number) ndata))
    (hbuf : ∀ v ∈ args, ArgBufOK F K W s S.tab.length v) (hbool : ∀ ty v, Val.str ty ∈ tys → v ∈ args → BoolOK K ty v)
    (hpre : ∀ asR S1, interpS (decodeArgs F s tys args).run S = some (some asR, S1) → Pre ν S1 s.ffi asR)
    (hcall : SizeCallSim F FR name (Present s) Pre) :
    MSim (fun M' S' C' s1 t1 => (Grow M ν S C M' S' C' ∧
      RelB F FR W stk M' ν ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
      ∃ asR ret asR' ret' v, s1.trace = ⟨name, asR, ret⟩ :: s.trace ∧ t1.trace = ⟨name, asR', ret'⟩ :: t.trace ∧
        numRet ret = some v ∧ numRet ret' = some (M'.val v)) ∧ runC F 3 t C = some (t1, C')) S C
      (sizeS F s) (sizeS F t) := by
  -- the callee, its signature and `Number`, unframed
  have hfrS : K.fr fsym = none :=
    h.bi_fr hfo (by rw [hk]; intro es he; cases he) (by rw [hk]; exact fun hw => hw)
  have hto : t.obj? (M.a fsym) = some (M.obj fo) := h.obj? hfo hfrS
  have htk' : (M.obj fo).kind = .fn (.native (.ffi .symbol) (M.vals [.str name, .obj ta, .str rt])) := by
    show M.kind fo.kind = _; rw [hk]; rfl
  have htc : t.ctl = .call (.obj (M.a fsym)) (M.val this) (M.vals args) := by
    rw [show t.ctl = _ from h.ctl, hc]; rfl
  have htt : t.obj? (M.a ta) = some (M.obj oa) := h.obj? hta hfr
  have hfrN : K.fr nf = none :=
    h.bi_fr hno (by rw [hnk]; intro es he; cases he) (by rw [hnk]; exact fun hw => hw)
  have htN : t.obj? (M.a nf) = some (M.obj no) := h.obj? hno hfrN
  have htNk : (M.obj no).kind = .fn (.native (.num .number) (M.vals ndata)) := by
    show M.kind no.kind = _; rw [hnk]; rfl
  have hso : Supp.vals (Present s) S.tab.length tys := by
    have := (h.obj?_supp hta).1; rw [htk] at this; exact this
  have hargs := (call_supp h hc).2
  obtain ⟨hts, -⟩ := h.pop hst
  obtain ⟨kd, pr, ps, pv, ex⟩ := oa
  simp only at htk
  subst htk
  have htA : t.obj? (M.a ta) = some ⟨.array (M.vals tys), M.val pr, M.props ps, M.privs pv, ex⟩ := by
    rw [htt]; rfl
  -- the native calls
  have es : step F s = Host.Ts.M.bind (decodeArgs F s tys args) (Disp.symK F s name rt) := by
    have e : step F s = callNative F s (.ffi .symbol) [.str name, .obj ta, .str rt] this args := by
      simp only [step, hc, callStep, hfo, hk]
    rw [e]
    show ffiN F s this args [.str name, .obj ta, .str rt] .symbol = _
    exact ffiN_symbol_eq hta
  have et : step F t = Host.Ts.M.bind (decodeArgs F t (M.vals tys) (M.vals args)) (Disp.symK F t name rt) := by
    have e : step F t = callNative F t (.ffi .symbol) (M.vals [.str name, .obj ta, .str rt]) (M.val this)
        (M.vals args) := by
      simp only [step, htc, callStep, hto, htk']
    rw [e]
    show ffiN F t (M.val this) (M.vals args) [.str name, .obj (M.a ta), .str rt] .symbol = _
    exact ffiN_symbol_eq htA
  unfold sizeS
  rw [es, et, mbind_assoc', mbind_assoc']
  refine MSim.bind (MSim.both (decodeArgs_sim hFR hF tys args h hso hargs hbuf hbool)
    (decodeArgs_lawful _ _ _ _) (decodeArgs_lawful _ _ _ _)) ?_
  rintro M1 S1 C1 r r' ⟨⟨rfl, g1, hs1⟩, hrun, hrunT⟩
  cases r with
  | none => exact MSim.fail _ _
  | some asR =>
    have h1 := h.grow hFR g1
    have hc1 := hcall M1 ν S1 C1 s.ffi t.ffi asR h1.srv h1.ffi (hs1 asR rfl) (hpre asR S1 hrun)
    show MSim _ S1 C1 (Host.Ts.M.bind (Disp.symK F s name rt (some asR)) _)
      (Host.Ts.M.bind (Disp.symK F t name rt (some (asR.map M1.arg))) _)
    simp only [Disp.symK]
    rw [mbind_assoc', mbind_assoc']
    refine MSim.bind (MSim.both hc1 (hL.call _ _ _) (hL.call _ _ _)) ?_
    rintro M2 S2 C2 cr cr' ⟨⟨g2, hd⟩, callS, callT⟩
    cases cr with
    | none => exact MSim.fail _ _
    | some p =>
      obtain ⟨x, ret, ws⟩ := p
      cases cr' with
      | none => exact hd.elim
      | some p' =>
        obtain ⟨y, ret', ws'⟩ := p'
        obtain ⟨hxy, rfl, rfl, v, hv, hv', hsv⟩ := hd
        rw [ffiDone_nocb (numRet_nocb hv), ffiDone_nocb (numRet_nocb hv')]
        have g := g1.trans g2
        let es := (⟨name, asR, ret⟩ : Event) :: s.trace
        let et' := (⟨name, asR.map M1.arg, ret'⟩ : Event) :: t.trace
        show MSim _ S2 C2 (Host.Ts.M.bind (step F (((s.setFfi x).setTrace es).ret (retVal ret))) (step F))
          (Host.Ts.M.bind (step F (((t.setFfi y).setTrace et').ret (retVal ret'))) (step F))
        have h2 := ((h.grow hFR g).setFfi x y hxy).setTraceBase es et'
        obtain ⟨hts2, h3⟩ := h2.pop hst
        have htN2 : ((t.setFfi y).setTrace et').obj? (M2.a nf) = some (M.obj no) := by
          rw [g.ext.a]; exact htN
        have stepT : interpC (step F t).run C =
            some ((((t.setFfi y).setTrace et').ret (retVal ret')), C2) := by
          rw [et]
          change interpC ((decodeArgs F t (M.vals tys) (M.vals args)) _
            (fun r => (Disp.symK F t name rt r).run)) C = _
          rw [(decodeArgs_lawful _ _ _ _).2, hrunT]
          simp only [Option.bind_some]
          unfold Disp.symK
          change interpC ((F.call t.ffi name (asR.map M1.arg)) _
            (fun r => (ffiDone F t name (asR.map M1.arg) r).run)) C1 = _
          rw [(hL.call _ _ _).2, callT]
          simp only [Option.bind_some]
          rw [ffiDone_nocb (numRet_nocb hv')]
          rfl
        have run1 : runC F 1 t C =
            some ((((t.setFfi y).setTrace et').ret (retVal ret')), C2) :=
          runC_one (by rw [htc]; rfl) stepT
        have run2 := tailRun (F := F)
          (u := ((t.setFfi y).setTrace et').ret (retVal ret'))
          (C := C2) (nf := M2.a nf) rfl hts2 htN2 htNk hv'
        have run3 := runC_trans run1 run2
        rw [size_tail (u := ((s.setFfi x).setTrace es).ret (retVal ret)) rfl hst hno hnk hv,
          size_tail (u := ((t.setFfi y).setTrace et').ret (retVal ret')) (nf := M2.a nf) rfl hts2 htN2 htNk hv']
        exact MSim.pure ⟨⟨g, h3.ret v hsv, asR, ret, _, ret', v, rfl, rfl, hv, hv'⟩, run3⟩

end
end Host.Load.Run.Tpl.D1BodySize

-- rechecked: literal chunk length
