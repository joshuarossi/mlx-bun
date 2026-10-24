import host.sim.stage.NextStep
set_option Elab.async false
namespace Host.Ts.Sim.Stage.NextStep
open Host.Ts Host.Ts.Sim.Stage
open Host.Ts.Sim.Prefill (PStep Phase nextStep phaseOf)

/-! # The `nextPrefillStep` stage contract, per class

For each class (`NextStepRun`): the facts of its chain read by the kernel (the call state is
`DCby`'s, the server is the template table with the class oracle, the return state returns
the object at `a`, the table entry of `end`, the heap only gains fresh entries, jobs, stores
and trace unchanged), the oracle's box (`goodLin`), and the class theorem (`*.holds`).
`prefillStage_holds`: the five classes cover `Dom`. -/

theorem eval_add12 (L p C : Nat) (h : L ≤ 2251799813685248 ∧ p < L ∧ C ≤ 2251799813685248) :
    SymE.eval (ρd L p C) (.bin .add (.var 1) (.var 2)) = Lin.ie (p + C : Nat) := by
  simp only [SymE.eval]
  rw [ρd_1 L p C (by omega), ρd_2 L p C (by omega)]
  show F64.add _ _ = _
  rw [Lin.add_ie _ _ (by omega)]
  exact ie_cast (by omega)

theorem eval_tail (L p C : Nat) (h : L ≤ 2251799813685248) (h2 : 2 ≤ L - p) :
    SymE.eval (ρd L p C) (.bin .add (.var 1) (.bin .sub (.bin .sub (.var 0) (.var 1)) (.lit (.fin false 1 0)))) =
      Lin.ie (L - 1 : Nat) := by
  simp only [SymE.eval]
  rw [ρd_0 L p C (by omega), ρd_1 L p C (by omega), one_ie]
  show F64.add _ (F64.sub (F64.sub _ _) _) = _
  rw [Lin.sub_ie _ _ (by omega), Lin.sub_ie _ _ (by omega), Lin.add_ie _ _ (by omega)]
  exact ie_cast (by omega)

theorem eval_v0 (L p C : Nat) (h : L ≤ 2251799813685248) : SymE.eval (ρd L p C) (.var 0) = Lin.ie (L : Nat) :=
  ρd_0 L p C (by omega)

theorem srv_inst {O : List Ans} (L p C : Nat) (hg : Good (ρd L p C) O) :
    Inst (ρd L p C) ⟨tab, O⟩ (callSrv L p C) :=
  ⟨by simp [callSrv, tab, ρd, SymE.eval], hg⟩

/-! ## Class `DCby` -/

kernel_rfl DCby.srv1 : DCby.S1 = ⟨tab, DCby.O⟩
kernel_rfl DCby.ret : DCby.s3.ctl = .ret (.obj 272)
kernel_rfl DCby.obj : DCby.s3.heap.get 272 =
  some (.obj ⟨.ordinary, .obj aObjectProto, stepProps (.num (.ref 1)) (.num (.ref 8)) false true .chunk, [], true⟩)
kernel_rfl DCby.e1 : nth? DCby.S3.tab 1 = some (.var 1)
kernel_rfl DCby.eE : nth? DCby.S3.tab 8 = some (.bin .add (.var 1) (.var 2))
kernel_rfl DCby.heapEq : DCby.s3.heap = setAll DCby.s1.heap (freshOf DCby.s3.heap DCby.s1.next DCby.s3.next)
kernel_rfl DCby.nextLe : Nat.ble DCby.s1.next DCby.s3.next = true
kernel_rfl DCby.small : Nat.blt DCby.s3.next 1048576 = true
kernel_rfl DCby.freshA : Nat.ble DCby.s1.next 272 = true
kernel_rfl DCby.jobs : DCby.s3.aux.jobs = DCby.s1.aux.jobs
kernel_rfl DCby.stores : DCby.s3.aux.stores = DCby.s1.aux.stores
kernel_rfl DCby.trace : DCby.s3.aux.trace = DCby.s1.aux.trace

/-- The box of class `DCby`'s inputs. -/
def DCby.ps : List Lin.Prm := [{ lo := 0, hi := 2251799813685248 }, { lo := 2, hi := 2251799813685248 }, { lo := 0, hi := 2251799813685248 }]
def DCby.V : List (Nat × Lin.Aff) := [(0, Lin.P 0 + Lin.P 1 + Lin.P 2 + 2), (1, Lin.P 0), (2, Lin.P 1)]

theorem DCby.lin : Lin.goodLin DCby.ps DCby.V DCby.O = true := by decide +kernel

/-- **Class `DCby`** (`C + 1 < L - p`). -/
theorem DCby.holds (F : Ffi) (x : F.S) (L p C : Nat) (hd : Dom L p C) (hc : C + 1 < L - p) :
    ∃ n t' C', (prefillStage F).Post (L, p, C) (callSt x) (callSrv L p C) t' C' ∧
      ∀ r, runC F n (under (callSt x) r) (callSrv L p C) = some (under t' r, C') := by
  have hb : L ≤ 2251799813685248 ∧ p < L ∧ C ≤ 2251799813685248 := ⟨hd.2.2.1, hd.2.1, hd.2.2.2⟩
  obtain ⟨hC2, hpL, hLb, hCb⟩ := hd
  have hg : Good (ρd L p C) DCby.O :=
    Lin.goodLin_sound DCby.lin (x := Lin.vx [(p : Int), (C : Int), (L : Int) - p - C - 2]) (by simp only [DCby.ps]; lin_mem) (by simp only [DCby.V]; lin_mem [ρd])
  have hi : Inst (ρd L p C) DCby.S1 (callSrv L p C) := by rw [DCby.srv1]; exact srv_inst L p C hg
  obtain ⟨_, hrun⟩ := tpl_sim DCby.stage F x hi
  have hcall : callSt x = tpl DCby.s1 0 x [] := by
    rfl
  refine ⟨226, tpl DCby.s3 0 x [], srv3 DCby.S3 L p C, ⟨?_, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x DCby.heapEq DCby.nextLe DCby.small DCby.jobs DCby.stores DCby.trace
  · have hs : nextStep L p C = _ := nextStep_dc hC2 (by omega)
    have hbo : batchOf L p C = true := by simp [batchOf]; omega
    simp only
    rw [hs, hbo]
    refine ⟨272, .num (.ref 1), .num (.ref 8), DCby.ret, ?_, ?_, ?_, ?_⟩
    · rw [hcall]; exact Nat.le_of_ble_eq_true DCby.freshA
    · exact DCby.obj
    · show natAt _ (.num (.ref 1)) = some p
      exact natAt_ref (by rw [nth_inst DCby.e1]; exact congrArg some (ρd_1 L p C (by omega))) (by omega)
    · show natAt _ (.num (.ref 8)) = some (p + C)
      exact natAt_ref (by rw [nth_inst DCby.eE]; exact congrArg some (eval_add12 L p C (by omega))) (by omega)
  · intro r; rw [hcall]; exact hrun r

/-! ## Class `DCeq` -/

kernel_rfl DCeq.call : DCeq.s1 = DCby.s1
kernel_rfl DCeq.srv1 : DCeq.S1 = ⟨tab, DCeq.O⟩
kernel_rfl DCeq.ret : DCeq.s3.ctl = .ret (.obj 272)
kernel_rfl DCeq.obj : DCeq.s3.heap.get 272 =
  some (.obj ⟨.ordinary, .obj aObjectProto, stepProps (.num (.ref 1)) (.num (.ref 8)) false false .chunk, [], true⟩)
kernel_rfl DCeq.e1 : nth? DCeq.S3.tab 1 = some (.var 1)
kernel_rfl DCeq.eE : nth? DCeq.S3.tab 8 = some (.bin .add (.var 1) (.var 2))
kernel_rfl DCeq.heapEq : DCeq.s3.heap = setAll DCeq.s1.heap (freshOf DCeq.s3.heap DCeq.s1.next DCeq.s3.next)
kernel_rfl DCeq.nextLe : Nat.ble DCeq.s1.next DCeq.s3.next = true
kernel_rfl DCeq.small : Nat.blt DCeq.s3.next 1048576 = true
kernel_rfl DCeq.freshA : Nat.ble DCeq.s1.next 272 = true
kernel_rfl DCeq.jobs : DCeq.s3.aux.jobs = DCeq.s1.aux.jobs
kernel_rfl DCeq.stores : DCeq.s3.aux.stores = DCeq.s1.aux.stores
kernel_rfl DCeq.trace : DCeq.s3.aux.trace = DCeq.s1.aux.trace

/-- The box of class `DCeq`'s inputs. -/
def DCeq.ps : List Lin.Prm := [{ lo := 0, hi := 2251799813685248 }, { lo := 2, hi := 2251799813685248 }]
def DCeq.V : List (Nat × Lin.Aff) := [(0, Lin.P 0 + Lin.P 1 + 1), (1, Lin.P 0), (2, Lin.P 1)]

theorem DCeq.lin : Lin.goodLin DCeq.ps DCeq.V DCeq.O = true := by decide +kernel

/-- **Class `DCeq`** (`L - p - 1 = C`). -/
theorem DCeq.holds (F : Ffi) (x : F.S) (L p C : Nat) (hd : Dom L p C) (hc : L - p - 1 = C) :
    ∃ n t' C', (prefillStage F).Post (L, p, C) (callSt x) (callSrv L p C) t' C' ∧
      ∀ r, runC F n (under (callSt x) r) (callSrv L p C) = some (under t' r, C') := by
  have hb : L ≤ 2251799813685248 ∧ p < L ∧ C ≤ 2251799813685248 := ⟨hd.2.2.1, hd.2.1, hd.2.2.2⟩
  obtain ⟨hC2, hpL, hLb, hCb⟩ := hd
  have hg : Good (ρd L p C) DCeq.O :=
    Lin.goodLin_sound DCeq.lin (x := Lin.vx [(p : Int), (C : Int)]) (by simp only [DCeq.ps]; lin_mem) (by simp only [DCeq.V]; lin_mem [ρd])
  have hi : Inst (ρd L p C) DCeq.S1 (callSrv L p C) := by rw [DCeq.srv1]; exact srv_inst L p C hg
  obtain ⟨_, hrun⟩ := tpl_sim DCeq.stage F x hi
  have hcall : callSt x = tpl DCeq.s1 0 x [] := by
    unfold callSt; rw [DCeq.call]
  refine ⟨226, tpl DCeq.s3 0 x [], srv3 DCeq.S3 L p C, ⟨?_, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x DCeq.heapEq DCeq.nextLe DCeq.small DCeq.jobs DCeq.stores DCeq.trace
  · have hs : nextStep L p C = _ := nextStep_dc hC2 (by omega)
    have hbo : batchOf L p C = false := by simp [batchOf]; omega
    simp only
    rw [hs, hbo]
    refine ⟨272, .num (.ref 1), .num (.ref 8), DCeq.ret, ?_, ?_, ?_, ?_⟩
    · rw [hcall]; exact Nat.le_of_ble_eq_true DCeq.freshA
    · exact DCeq.obj
    · show natAt _ (.num (.ref 1)) = some p
      exact natAt_ref (by rw [nth_inst DCeq.e1]; exact congrArg some (ρd_1 L p C (by omega))) (by omega)
    · show natAt _ (.num (.ref 8)) = some (p + C)
      exact natAt_ref (by rw [nth_inst DCeq.eE]; exact congrArg some (eval_add12 L p C (by omega))) (by omega)
  · intro r; rw [hcall]; exact hrun r

/-! ## Class `DTtail` -/

kernel_rfl DTtail.call : DTtail.s1 = DCby.s1
kernel_rfl DTtail.srv1 : DTtail.S1 = ⟨tab, DTtail.O⟩
kernel_rfl DTtail.ret : DTtail.s3.ctl = .ret (.obj 272)
kernel_rfl DTtail.obj : DTtail.s3.heap.get 272 =
  some (.obj ⟨.ordinary, .obj aObjectProto, stepProps (.num (.ref 1)) (.num (.ref 9)) false false .tail, [], true⟩)
kernel_rfl DTtail.e1 : nth? DTtail.S3.tab 1 = some (.var 1)
kernel_rfl DTtail.eE : nth? DTtail.S3.tab 9 = some (.bin .add (.var 1) (.bin .sub (.bin .sub (.var 0) (.var 1)) (.lit (.fin false 1 0))))
kernel_rfl DTtail.heapEq : DTtail.s3.heap = setAll DTtail.s1.heap (freshOf DTtail.s3.heap DTtail.s1.next DTtail.s3.next)
kernel_rfl DTtail.nextLe : Nat.ble DTtail.s1.next DTtail.s3.next = true
kernel_rfl DTtail.small : Nat.blt DTtail.s3.next 1048576 = true
kernel_rfl DTtail.freshA : Nat.ble DTtail.s1.next 272 = true
kernel_rfl DTtail.jobs : DTtail.s3.aux.jobs = DTtail.s1.aux.jobs
kernel_rfl DTtail.stores : DTtail.s3.aux.stores = DTtail.s1.aux.stores
kernel_rfl DTtail.trace : DTtail.s3.aux.trace = DTtail.s1.aux.trace

/-- The box of class `DTtail`'s inputs. -/
def DTtail.ps : List Lin.Prm := [{ lo := 0, hi := 2251799813685248 }, { lo := 0, hi := 2251799813685248 }, { lo := 0, hi := 2251799813685248 }]
def DTtail.V : List (Nat × Lin.Aff) := [(0, Lin.P 0 + Lin.P 1 + 3), (1, Lin.P 0), (2, Lin.P 1 + Lin.P 2 + 3)]

theorem DTtail.lin : Lin.goodLin DTtail.ps DTtail.V DTtail.O = true := by decide +kernel

/-- **Class `DTtail`** (`3 ≤ L - p ∧ L - p - 1 < C`). -/
theorem DTtail.holds (F : Ffi) (x : F.S) (L p C : Nat) (hd : Dom L p C) (hc : 3 ≤ L - p ∧ L - p - 1 < C) :
    ∃ n t' C', (prefillStage F).Post (L, p, C) (callSt x) (callSrv L p C) t' C' ∧
      ∀ r, runC F n (under (callSt x) r) (callSrv L p C) = some (under t' r, C') := by
  have hb : L ≤ 2251799813685248 ∧ p < L ∧ C ≤ 2251799813685248 := ⟨hd.2.2.1, hd.2.1, hd.2.2.2⟩
  obtain ⟨hC2, hpL, hLb, hCb⟩ := hd
  have hg : Good (ρd L p C) DTtail.O :=
    Lin.goodLin_sound DTtail.lin (x := Lin.vx [(p : Int), (L : Int) - p - 3, (C : Int) - ((L : Int) - p)]) (by simp only [DTtail.ps]; lin_mem) (by simp only [DTtail.V]; lin_mem [ρd])
  have hi : Inst (ρd L p C) DTtail.S1 (callSrv L p C) := by rw [DTtail.srv1]; exact srv_inst L p C hg
  obtain ⟨_, hrun⟩ := tpl_sim DTtail.stage F x hi
  have hcall : callSt x = tpl DTtail.s1 0 x [] := by
    unfold callSt; rw [DTtail.call]
  refine ⟨230, tpl DTtail.s3 0 x [], srv3 DTtail.S3 L p C, ⟨?_, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x DTtail.heapEq DTtail.nextLe DTtail.small DTtail.jobs DTtail.stores DTtail.trace
  · have hs : nextStep L p C = _ := nextStep_dt (by omega) (by omega)
    have hbo : batchOf L p C = false := by simp [batchOf]; omega
    simp only
    rw [hs, hbo]
    rw [ite_eq_right (show ¬ (L - p = 2) by omega)]
    refine ⟨272, .num (.ref 1), .num (.ref 9), DTtail.ret, ?_, ?_, ?_, ?_⟩
    · rw [hcall]; exact Nat.le_of_ble_eq_true DTtail.freshA
    · exact DTtail.obj
    · show natAt _ (.num (.ref 1)) = some p
      exact natAt_ref (by rw [nth_inst DTtail.e1]; exact congrArg some (ρd_1 L p C (by omega))) (by omega)
    · show natAt _ (.num (.ref 9)) = some (L - 1)
      exact natAt_ref (by rw [nth_inst DTtail.eE]; exact congrArg some (eval_tail L p C (by omega) (by omega))) (by omega)
  · intro r; rw [hcall]; exact hrun r

/-! ## Class `DTdec` -/

kernel_rfl DTdec.call : DTdec.s1 = DCby.s1
kernel_rfl DTdec.srv1 : DTdec.S1 = ⟨tab, DTdec.O⟩
kernel_rfl DTdec.ret : DTdec.s3.ctl = .ret (.obj 272)
kernel_rfl DTdec.obj : DTdec.s3.heap.get 272 =
  some (.obj ⟨.ordinary, .obj aObjectProto, stepProps (.num (.ref 1)) (.num (.ref 9)) false false .decode, [], true⟩)
kernel_rfl DTdec.e1 : nth? DTdec.S3.tab 1 = some (.var 1)
kernel_rfl DTdec.eE : nth? DTdec.S3.tab 9 = some (.bin .add (.var 1) (.bin .sub (.bin .sub (.var 0) (.var 1)) (.lit (.fin false 1 0))))
kernel_rfl DTdec.heapEq : DTdec.s3.heap = setAll DTdec.s1.heap (freshOf DTdec.s3.heap DTdec.s1.next DTdec.s3.next)
kernel_rfl DTdec.nextLe : Nat.ble DTdec.s1.next DTdec.s3.next = true
kernel_rfl DTdec.small : Nat.blt DTdec.s3.next 1048576 = true
kernel_rfl DTdec.freshA : Nat.ble DTdec.s1.next 272 = true
kernel_rfl DTdec.jobs : DTdec.s3.aux.jobs = DTdec.s1.aux.jobs
kernel_rfl DTdec.stores : DTdec.s3.aux.stores = DTdec.s1.aux.stores
kernel_rfl DTdec.trace : DTdec.s3.aux.trace = DTdec.s1.aux.trace

/-- The box of class `DTdec`'s inputs. -/
def DTdec.ps : List Lin.Prm := [{ lo := 0, hi := 2251799813685248 }, { lo := 2, hi := 2251799813685248 }]
def DTdec.V : List (Nat × Lin.Aff) := [(0, Lin.P 0 + 2), (1, Lin.P 0), (2, Lin.P 1)]

theorem DTdec.lin : Lin.goodLin DTdec.ps DTdec.V DTdec.O = true := by decide +kernel

/-- **Class `DTdec`** (`L - p = 2`). -/
theorem DTdec.holds (F : Ffi) (x : F.S) (L p C : Nat) (hd : Dom L p C) (hc : L - p = 2) :
    ∃ n t' C', (prefillStage F).Post (L, p, C) (callSt x) (callSrv L p C) t' C' ∧
      ∀ r, runC F n (under (callSt x) r) (callSrv L p C) = some (under t' r, C') := by
  have hb : L ≤ 2251799813685248 ∧ p < L ∧ C ≤ 2251799813685248 := ⟨hd.2.2.1, hd.2.1, hd.2.2.2⟩
  obtain ⟨hC2, hpL, hLb, hCb⟩ := hd
  have hg : Good (ρd L p C) DTdec.O :=
    Lin.goodLin_sound DTdec.lin (x := Lin.vx [(p : Int), (C : Int)]) (by simp only [DTdec.ps]; lin_mem) (by simp only [DTdec.V]; lin_mem [ρd])
  have hi : Inst (ρd L p C) DTdec.S1 (callSrv L p C) := by rw [DTdec.srv1]; exact srv_inst L p C hg
  obtain ⟨_, hrun⟩ := tpl_sim DTdec.stage F x hi
  have hcall : callSt x = tpl DTdec.s1 0 x [] := by
    unfold callSt; rw [DTdec.call]
  refine ⟨227, tpl DTdec.s3 0 x [], srv3 DTdec.S3 L p C, ⟨?_, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x DTdec.heapEq DTdec.nextLe DTdec.small DTdec.jobs DTdec.stores DTdec.trace
  · have hs : nextStep L p C = _ := nextStep_dt (by omega) (by omega)
    have hbo : batchOf L p C = false := by simp [batchOf]; omega
    simp only
    rw [hs, hbo]
    rw [ite_eq_left (show L - p = 2 by omega)]
    refine ⟨272, .num (.ref 1), .num (.ref 9), DTdec.ret, ?_, ?_, ?_, ?_⟩
    · rw [hcall]; exact Nat.le_of_ble_eq_true DTdec.freshA
    · exact DTdec.obj
    · show natAt _ (.num (.ref 1)) = some p
      exact natAt_ref (by rw [nth_inst DTdec.e1]; exact congrArg some (ρd_1 L p C (by omega))) (by omega)
    · show natAt _ (.num (.ref 9)) = some (L - 1)
      exact natAt_ref (by rw [nth_inst DTdec.eE]; exact congrArg some (eval_tail L p C (by omega) (by omega))) (by omega)
  · intro r; rw [hcall]; exact hrun r

/-! ## Class `FIN` -/

kernel_rfl FIN.call : FIN.s1 = DCby.s1
kernel_rfl FIN.srv1 : FIN.S1 = ⟨tab, FIN.O⟩
kernel_rfl FIN.ret : FIN.s3.ctl = .ret (.obj 270)
kernel_rfl FIN.obj : FIN.s3.heap.get 270 =
  some (.obj ⟨.ordinary, .obj aObjectProto, stepProps (.num (.ref 1)) (.num (.ref 0)) true false .decode, [], true⟩)
kernel_rfl FIN.e1 : nth? FIN.S3.tab 1 = some (.var 1)
kernel_rfl FIN.eE : nth? FIN.S3.tab 0 = some (.var 0)
kernel_rfl FIN.heapEq : FIN.s3.heap = setAll FIN.s1.heap (freshOf FIN.s3.heap FIN.s1.next FIN.s3.next)
kernel_rfl FIN.nextLe : Nat.ble FIN.s1.next FIN.s3.next = true
kernel_rfl FIN.small : Nat.blt FIN.s3.next 1048576 = true
kernel_rfl FIN.freshA : Nat.ble FIN.s1.next 270 = true
kernel_rfl FIN.jobs : FIN.s3.aux.jobs = FIN.s1.aux.jobs
kernel_rfl FIN.stores : FIN.s3.aux.stores = FIN.s1.aux.stores
kernel_rfl FIN.trace : FIN.s3.aux.trace = FIN.s1.aux.trace

/-- The box of class `FIN`'s inputs. -/
def FIN.ps : List Lin.Prm := [{ lo := 0, hi := 2251799813685248 }, { lo := 2, hi := 2251799813685248 }]
def FIN.V : List (Nat × Lin.Aff) := [(0, Lin.P 0 + 1), (1, Lin.P 0), (2, Lin.P 1)]

theorem FIN.lin : Lin.goodLin FIN.ps FIN.V FIN.O = true := by decide +kernel

/-- **Class `FIN`** (`L - p = 1`). -/
theorem FIN.holds (F : Ffi) (x : F.S) (L p C : Nat) (hd : Dom L p C) (hc : L - p = 1) :
    ∃ n t' C', (prefillStage F).Post (L, p, C) (callSt x) (callSrv L p C) t' C' ∧
      ∀ r, runC F n (under (callSt x) r) (callSrv L p C) = some (under t' r, C') := by
  have hb : L ≤ 2251799813685248 ∧ p < L ∧ C ≤ 2251799813685248 := ⟨hd.2.2.1, hd.2.1, hd.2.2.2⟩
  obtain ⟨hC2, hpL, hLb, hCb⟩ := hd
  have hg : Good (ρd L p C) FIN.O :=
    Lin.goodLin_sound FIN.lin (x := Lin.vx [(p : Int), (C : Int)]) (by simp only [FIN.ps]; lin_mem) (by simp only [FIN.V]; lin_mem [ρd])
  have hi : Inst (ρd L p C) FIN.S1 (callSrv L p C) := by rw [FIN.srv1]; exact srv_inst L p C hg
  obtain ⟨_, hrun⟩ := tpl_sim FIN.stage F x hi
  have hcall : callSt x = tpl FIN.s1 0 x [] := by
    unfold callSt; rw [FIN.call]
  refine ⟨180, tpl FIN.s3 0 x [], srv3 FIN.S3 L p C, ⟨?_, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x FIN.heapEq FIN.nextLe FIN.small FIN.jobs FIN.stores FIN.trace
  · have hs : nextStep L p C = _ := nextStep_fin (by omega)
    have hbo : batchOf L p C = false := by simp [batchOf]; omega
    simp only
    rw [hs, hbo]
    refine ⟨270, .num (.ref 1), .num (.ref 0), FIN.ret, ?_, ?_, ?_, ?_⟩
    · rw [hcall]; exact Nat.le_of_ble_eq_true FIN.freshA
    · exact FIN.obj
    · show natAt _ (.num (.ref 1)) = some p
      exact natAt_ref (by rw [nth_inst FIN.e1]; exact congrArg some (ρd_1 L p C (by omega))) (by omega)
    · show natAt _ (.num (.ref 0)) = some (L)
      exact natAt_ref (by rw [nth_inst FIN.eE]; exact congrArg some (eval_v0 L p C (by omega))) (by omega)
  · intro r; rw [hcall]; exact hrun r

/-! ## The contract -/

/-- **The `nextPrefillStep` stage holds**: for every FFI, native state and caller stack, the call
returns the Lean schedule step `nextStep L p C` and changes nothing else. -/
theorem prefillStage_holds (F : Ffi) : (prefillStage F).Holds := by
  rintro ⟨L, p, C⟩ t Cs ⟨hd, ⟨x, rfl⟩, rfl⟩
  have hpL : p < L := hd.2.1
  by_cases h1 : L - p = 1
  · exact FIN.holds F x L p C hd h1
  by_cases h2 : L - p = 2
  · exact DTdec.holds F x L p C hd h2
  by_cases h3 : L - p - 1 < C
  · exact DTtail.holds F x L p C hd ⟨by omega, h3⟩
  by_cases h4 : L - p - 1 = C
  · exact DCeq.holds F x L p C hd h4
  · exact DCby.holds F x L p C hd (by omega)

/-- The stage in every context: the frame rule with any caller fact `I`. -/
theorem prefillStage_ctx (F : Ffi) (I : (prefillStage F).Par → St F.S → CSrv → List Frame → Prop) :
    Seg F ((prefillStage F).AtCall I) ((prefillStage F).AtRet I) :=
  Stage.frame (prefillStage_holds F) I

/-- A pure stage allocates and frees no native handle, under every liveness layer. -/
theorem prefillStage_live (F : Ffi) (live : F.S → Nat → Prop) {q : (prefillStage F).Par} {t t' : St F.S} {C C' : CSrv}
    (h : (prefillStage F).Post q t C t' C') : LiveDelta live (fun _ => False) (fun _ => False) t.ffi t'.ffi := by
  rw [← h.1.ffi]; exact LiveDelta.refl live t.ffi

end Host.Ts.Sim.Stage.NextStep
