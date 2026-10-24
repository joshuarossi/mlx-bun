import host.sim.stage.Read
import host.sim.stage.ChunkRun
import host.sim.PrefillSched
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Ts.Sim.Stage.ChunkSize
open Host.Ts Host.Ts.Sim.Stage
open Host.Ts.Sim.Prefill (chunkC chunkC_eq)

/-! # The `chunkSize` stage contract

`policy.chunkSize(L)` returns the Lean chunk size `chunkC L` (`host.sim.PrefillSched`) for every
`1 ≤ L ≤ 349525`, and changes nothing else (no existing heap entry written, jobs, stores, trace
and native state unchanged), under every FFI, native state and caller stack
(`chunkStage_holds`). The call state is the template's (`chunkCall x`: the policy the driver
built over the route's geometry), the server holds `L`. -/

/-- The isolated call state, native state `x`. -/
noncomputable def chunkCall {S : Type} (x : S) : St S := tpl K8.s1 0 x []

/-- The call's number server: `L`. -/
def chunkSrv (L : Nat) : CSrv := ⟨[F64.ofNat L]⟩

/-- **The stage**: parameter `L`. -/
def chunkStage (F : Ffi) : Stage F where
  Par := Nat
  Pre L t C := 1 ≤ L ∧ L ≤ 349525 ∧ (∃ x, t = chunkCall x) ∧ C = chunkSrv L
  Post L t _ t' C' := Framed (fun _ => False) Eq t t' ∧ ∃ v, t'.ctl = .ret v ∧ natAt C' v = some (chunkC L)

theorem chunk_inst {O : List Ans} (L : Nat) (hg : Good (ρL L) O) : Inst (ρL L) ⟨[.var 0], O⟩ (chunkSrv L) :=
  ⟨by simp [chunkSrv, ρL, SymE.eval], hg⟩

/-! ## Class `K8`: `1 ≤ L ≤ 8`, chunk 2048 -/

kernel_rfl K8.srv1 : K8.S1 = ⟨[.var 0], K8.O⟩
kernel_rfl K8.ret : K8.s3.ctl = .ret (.num (.lit (.fin false 2048 0)))
kernel_rfl K8.heapEq : K8.s3.heap = setAll K8.s1.heap (freshOf K8.s3.heap K8.s1.next K8.s3.next)
kernel_rfl K8.nextLe : Nat.ble K8.s1.next K8.s3.next = true
kernel_rfl K8.small : Nat.blt K8.s3.next 1048576 = true
kernel_rfl K8.jobs : K8.s3.aux.jobs = K8.s1.aux.jobs
kernel_rfl K8.stores : K8.s3.aux.stores = K8.s1.aux.stores
kernel_rfl K8.trace : K8.s3.aux.trace = K8.s1.aux.trace

def K8.ps : List Lin.Prm := [{ lo := 1, hi := 8 }]
def K8.V : List (Nat × Lin.Aff) := [(0, Lin.P 0)]

theorem K8.lin : Lin.goodLin K8.ps K8.V K8.O = true := by decide +kernel

/-- **Class `K8`.** -/
theorem K8.holds (F : Ffi) (x : F.S) (L : Nat) (h1 : 1 ≤ L) (h2 : L ≤ 8) :
    ∃ n t' C', (chunkStage F).Post L (chunkCall x) (chunkSrv L) t' C' ∧
      ∀ r, runC F n (under (chunkCall x) r) (chunkSrv L) = some (under t' r, C') := by
  have hg : Good (ρL L) K8.O :=
    Lin.goodLin_sound K8.lin (x := Lin.vx [(L : Int)]) (by simp only [K8.ps]; lin_mem) (by simp only [K8.V]; lin_mem [ρL])
  have hi : Inst (ρL L) K8.S1 (chunkSrv L) := by rw [K8.srv1]; exact chunk_inst L hg
  obtain ⟨_, hrun⟩ := tpl_sim K8.stage F x hi
  have hcall : chunkCall x = tpl K8.s1 0 x [] := by
    rfl
  have hc : chunkC L = 2048 := by
    rw [chunkC_eq L (by omega)]
    repeat' split
    all_goals omega
  refine ⟨101, tpl K8.s3 0 x [], ⟨K8.S3.tab.map (SymE.eval (ρL L))⟩, ⟨?_, .num (.lit (.fin false 2048 0)), K8.ret, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x K8.heapEq K8.nextLe K8.small K8.jobs K8.stores K8.trace
  · rw [hc]; rfl
  · intro r; rw [hcall]; exact hrun r

/-! ## Class `K2048`: `9 ≤ L ≤ 10922`, chunk 2048 -/

kernel_rfl K2048.call : K2048.s1 = K8.s1
kernel_rfl K2048.srv1 : K2048.S1 = ⟨[.var 0], K2048.O⟩
kernel_rfl K2048.ret : K2048.s4.ctl = .ret (.num (.lit (.fin false 2048 0)))
kernel_rfl K2048.heapEq : K2048.s4.heap = setAll K2048.s1.heap (freshOf K2048.s4.heap K2048.s1.next K2048.s4.next)
kernel_rfl K2048.nextLe : Nat.ble K2048.s1.next K2048.s4.next = true
kernel_rfl K2048.small : Nat.blt K2048.s4.next 1048576 = true
kernel_rfl K2048.jobs : K2048.s4.aux.jobs = K2048.s1.aux.jobs
kernel_rfl K2048.stores : K2048.s4.aux.stores = K2048.s1.aux.stores
kernel_rfl K2048.trace : K2048.s4.aux.trace = K2048.s1.aux.trace

def K2048.ps : List Lin.Prm := [{ lo := 9, hi := 10922 }]
def K2048.V : List (Nat × Lin.Aff) := [(0, Lin.P 0)]

theorem K2048.lin : Lin.goodLin K2048.ps K2048.V K2048.O = true := by decide +kernel

/-- **Class `K2048`.** -/
theorem K2048.holds (F : Ffi) (x : F.S) (L : Nat) (h1 : 9 ≤ L) (h2 : L ≤ 10922) :
    ∃ n t' C', (chunkStage F).Post L (chunkCall x) (chunkSrv L) t' C' ∧
      ∀ r, runC F n (under (chunkCall x) r) (chunkSrv L) = some (under t' r, C') := by
  have hg : Good (ρL L) K2048.O :=
    Lin.goodLin_sound K2048.lin (x := Lin.vx [(L : Int)]) (by simp only [K2048.ps]; lin_mem) (by simp only [K2048.V]; lin_mem [ρL])
  have hi : Inst (ρL L) K2048.S1 (chunkSrv L) := by rw [K2048.srv1]; exact chunk_inst L hg
  obtain ⟨_, hrun⟩ := tpl_sim K2048.stage F x hi
  have hcall : chunkCall x = tpl K2048.s1 0 x [] := by
    unfold chunkCall; rw [K2048.call]
  have hc : chunkC L = 2048 := by
    rw [chunkC_eq L (by omega)]
    repeat' split
    all_goals omega
  refine ⟨5715, tpl K2048.s4 0 x [], ⟨K2048.S4.tab.map (SymE.eval (ρL L))⟩, ⟨?_, .num (.lit (.fin false 2048 0)), K2048.ret, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x K2048.heapEq K2048.nextLe K2048.small K2048.jobs K2048.stores K2048.trace
  · rw [hc]; rfl
  · intro r; rw [hcall]; exact hrun r

/-! ## Class `K1024`: `10923 ≤ L ≤ 21845`, chunk 1024 -/

kernel_rfl K1024.call : K1024.s1 = K8.s1
kernel_rfl K1024.srv1 : K1024.S1 = ⟨[.var 0], K1024.O⟩
kernel_rfl K1024.ret : K1024.s5.ctl = .ret (.num (.lit (.fin false 1024 0)))
kernel_rfl K1024.heapEq : K1024.s5.heap = setAll K1024.s1.heap (freshOf K1024.s5.heap K1024.s1.next K1024.s5.next)
kernel_rfl K1024.nextLe : Nat.ble K1024.s1.next K1024.s5.next = true
kernel_rfl K1024.small : Nat.blt K1024.s5.next 1048576 = true
kernel_rfl K1024.jobs : K1024.s5.aux.jobs = K1024.s1.aux.jobs
kernel_rfl K1024.stores : K1024.s5.aux.stores = K1024.s1.aux.stores
kernel_rfl K1024.trace : K1024.s5.aux.trace = K1024.s1.aux.trace

def K1024.ps : List Lin.Prm := [{ lo := 10923, hi := 21845 }]
def K1024.V : List (Nat × Lin.Aff) := [(0, Lin.P 0)]

theorem K1024.lin : Lin.goodLin K1024.ps K1024.V K1024.O = true := by decide +kernel

/-- **Class `K1024`.** -/
theorem K1024.holds (F : Ffi) (x : F.S) (L : Nat) (h1 : 10923 ≤ L) (h2 : L ≤ 21845) :
    ∃ n t' C', (chunkStage F).Post L (chunkCall x) (chunkSrv L) t' C' ∧
      ∀ r, runC F n (under (chunkCall x) r) (chunkSrv L) = some (under t' r, C') := by
  have hg : Good (ρL L) K1024.O :=
    Lin.goodLin_sound K1024.lin (x := Lin.vx [(L : Int)]) (by simp only [K1024.ps]; lin_mem) (by simp only [K1024.V]; lin_mem [ρL])
  have hi : Inst (ρL L) K1024.S1 (chunkSrv L) := by rw [K1024.srv1]; exact chunk_inst L hg
  obtain ⟨_, hrun⟩ := tpl_sim K1024.stage F x hi
  have hcall : chunkCall x = tpl K1024.s1 0 x [] := by
    unfold chunkCall; rw [K1024.call]
  have hc : chunkC L = 1024 := by
    rw [chunkC_eq L (by omega)]
    repeat' split
    all_goals omega
  refine ⟨11418, tpl K1024.s5 0 x [], ⟨K1024.S5.tab.map (SymE.eval (ρL L))⟩, ⟨?_, .num (.lit (.fin false 1024 0)), K1024.ret, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x K1024.heapEq K1024.nextLe K1024.small K1024.jobs K1024.stores K1024.trace
  · rw [hc]; rfl
  · intro r; rw [hcall]; exact hrun r

/-! ## Class `K512`: `21846 ≤ L ≤ 43690`, chunk 512 -/

kernel_rfl K512.call : K512.s1 = K8.s1
kernel_rfl K512.srv1 : K512.S1 = ⟨[.var 0], K512.O⟩
kernel_rfl K512.ret : K512.s6.ctl = .ret (.num (.lit (.fin false 512 0)))
kernel_rfl K512.heapEq : K512.s6.heap = setAll K512.s1.heap (freshOf K512.s6.heap K512.s1.next K512.s6.next)
kernel_rfl K512.nextLe : Nat.ble K512.s1.next K512.s6.next = true
kernel_rfl K512.small : Nat.blt K512.s6.next 1048576 = true
kernel_rfl K512.jobs : K512.s6.aux.jobs = K512.s1.aux.jobs
kernel_rfl K512.stores : K512.s6.aux.stores = K512.s1.aux.stores
kernel_rfl K512.trace : K512.s6.aux.trace = K512.s1.aux.trace

def K512.ps : List Lin.Prm := [{ lo := 21846, hi := 43690 }]
def K512.V : List (Nat × Lin.Aff) := [(0, Lin.P 0)]

theorem K512.lin : Lin.goodLin K512.ps K512.V K512.O = true := by decide +kernel

/-- **Class `K512`.** -/
theorem K512.holds (F : Ffi) (x : F.S) (L : Nat) (h1 : 21846 ≤ L) (h2 : L ≤ 43690) :
    ∃ n t' C', (chunkStage F).Post L (chunkCall x) (chunkSrv L) t' C' ∧
      ∀ r, runC F n (under (chunkCall x) r) (chunkSrv L) = some (under t' r, C') := by
  have hg : Good (ρL L) K512.O :=
    Lin.goodLin_sound K512.lin (x := Lin.vx [(L : Int)]) (by simp only [K512.ps]; lin_mem) (by simp only [K512.V]; lin_mem [ρL])
  have hi : Inst (ρL L) K512.S1 (chunkSrv L) := by rw [K512.srv1]; exact chunk_inst L hg
  obtain ⟨_, hrun⟩ := tpl_sim K512.stage F x hi
  have hcall : chunkCall x = tpl K512.s1 0 x [] := by
    unfold chunkCall; rw [K512.call]
  have hc : chunkC L = 512 := by
    rw [chunkC_eq L (by omega)]
    repeat' split
    all_goals omega
  refine ⟨17121, tpl K512.s6 0 x [], ⟨K512.S6.tab.map (SymE.eval (ρL L))⟩, ⟨?_, .num (.lit (.fin false 512 0)), K512.ret, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x K512.heapEq K512.nextLe K512.small K512.jobs K512.stores K512.trace
  · rw [hc]; rfl
  · intro r; rw [hcall]; exact hrun r

/-! ## Class `K256`: `43691 ≤ L ≤ 87381`, chunk 256 -/

kernel_rfl K256.call : K256.s1 = K8.s1
kernel_rfl K256.srv1 : K256.S1 = ⟨[.var 0], K256.O⟩
kernel_rfl K256.ret : K256.s7.ctl = .ret (.num (.lit (.fin false 256 0)))
kernel_rfl K256.heapEq : K256.s7.heap = setAll K256.s1.heap (freshOf K256.s7.heap K256.s1.next K256.s7.next)
kernel_rfl K256.nextLe : Nat.ble K256.s1.next K256.s7.next = true
kernel_rfl K256.small : Nat.blt K256.s7.next 1048576 = true
kernel_rfl K256.jobs : K256.s7.aux.jobs = K256.s1.aux.jobs
kernel_rfl K256.stores : K256.s7.aux.stores = K256.s1.aux.stores
kernel_rfl K256.trace : K256.s7.aux.trace = K256.s1.aux.trace

def K256.ps : List Lin.Prm := [{ lo := 43691, hi := 87381 }]
def K256.V : List (Nat × Lin.Aff) := [(0, Lin.P 0)]

theorem K256.lin : Lin.goodLin K256.ps K256.V K256.O = true := by decide +kernel

/-- **Class `K256`.** -/
theorem K256.holds (F : Ffi) (x : F.S) (L : Nat) (h1 : 43691 ≤ L) (h2 : L ≤ 87381) :
    ∃ n t' C', (chunkStage F).Post L (chunkCall x) (chunkSrv L) t' C' ∧
      ∀ r, runC F n (under (chunkCall x) r) (chunkSrv L) = some (under t' r, C') := by
  have hg : Good (ρL L) K256.O :=
    Lin.goodLin_sound K256.lin (x := Lin.vx [(L : Int)]) (by simp only [K256.ps]; lin_mem) (by simp only [K256.V]; lin_mem [ρL])
  have hi : Inst (ρL L) K256.S1 (chunkSrv L) := by rw [K256.srv1]; exact chunk_inst L hg
  obtain ⟨_, hrun⟩ := tpl_sim K256.stage F x hi
  have hcall : chunkCall x = tpl K256.s1 0 x [] := by
    unfold chunkCall; rw [K256.call]
  have hc : chunkC L = 256 := by
    rw [chunkC_eq L (by omega)]
    repeat' split
    all_goals omega
  refine ⟨22824, tpl K256.s7 0 x [], ⟨K256.S7.tab.map (SymE.eval (ρL L))⟩, ⟨?_, .num (.lit (.fin false 256 0)), K256.ret, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x K256.heapEq K256.nextLe K256.small K256.jobs K256.stores K256.trace
  · rw [hc]; rfl
  · intro r; rw [hcall]; exact hrun r

/-! ## Class `K128`: `87382 ≤ L ≤ 174762`, chunk 128 -/

kernel_rfl K128.call : K128.s1 = K8.s1
kernel_rfl K128.srv1 : K128.S1 = ⟨[.var 0], K128.O⟩
kernel_rfl K128.ret : K128.s8.ctl = .ret (.num (.lit (.fin false 128 0)))
kernel_rfl K128.heapEq : K128.s8.heap = setAll K128.s1.heap (freshOf K128.s8.heap K128.s1.next K128.s8.next)
kernel_rfl K128.nextLe : Nat.ble K128.s1.next K128.s8.next = true
kernel_rfl K128.small : Nat.blt K128.s8.next 1048576 = true
kernel_rfl K128.jobs : K128.s8.aux.jobs = K128.s1.aux.jobs
kernel_rfl K128.stores : K128.s8.aux.stores = K128.s1.aux.stores
kernel_rfl K128.trace : K128.s8.aux.trace = K128.s1.aux.trace

def K128.ps : List Lin.Prm := [{ lo := 87382, hi := 174762 }]
def K128.V : List (Nat × Lin.Aff) := [(0, Lin.P 0)]

theorem K128.lin : Lin.goodLin K128.ps K128.V K128.O = true := by decide +kernel

/-- **Class `K128`.** -/
theorem K128.holds (F : Ffi) (x : F.S) (L : Nat) (h1 : 87382 ≤ L) (h2 : L ≤ 174762) :
    ∃ n t' C', (chunkStage F).Post L (chunkCall x) (chunkSrv L) t' C' ∧
      ∀ r, runC F n (under (chunkCall x) r) (chunkSrv L) = some (under t' r, C') := by
  have hg : Good (ρL L) K128.O :=
    Lin.goodLin_sound K128.lin (x := Lin.vx [(L : Int)]) (by simp only [K128.ps]; lin_mem) (by simp only [K128.V]; lin_mem [ρL])
  have hi : Inst (ρL L) K128.S1 (chunkSrv L) := by rw [K128.srv1]; exact chunk_inst L hg
  obtain ⟨_, hrun⟩ := tpl_sim K128.stage F x hi
  have hcall : chunkCall x = tpl K128.s1 0 x [] := by
    unfold chunkCall; rw [K128.call]
  have hc : chunkC L = 128 := by
    rw [chunkC_eq L (by omega)]
    repeat' split
    all_goals omega
  refine ⟨28527, tpl K128.s8 0 x [], ⟨K128.S8.tab.map (SymE.eval (ρL L))⟩, ⟨?_, .num (.lit (.fin false 128 0)), K128.ret, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x K128.heapEq K128.nextLe K128.small K128.jobs K128.stores K128.trace
  · rw [hc]; rfl
  · intro r; rw [hcall]; exact hrun r

/-! ## Class `K64`: `174763 ≤ L ≤ 349525`, chunk 64 -/

kernel_rfl K64.call : K64.s1 = K8.s1
kernel_rfl K64.srv1 : K64.S1 = ⟨[.var 0], K64.O⟩
kernel_rfl K64.ret : K64.s9.ctl = .ret (.num (.lit (.fin false 64 0)))
kernel_rfl K64.heapEq : K64.s9.heap = setAll K64.s1.heap (freshOf K64.s9.heap K64.s1.next K64.s9.next)
kernel_rfl K64.nextLe : Nat.ble K64.s1.next K64.s9.next = true
kernel_rfl K64.small : Nat.blt K64.s9.next 1048576 = true
kernel_rfl K64.jobs : K64.s9.aux.jobs = K64.s1.aux.jobs
kernel_rfl K64.stores : K64.s9.aux.stores = K64.s1.aux.stores
kernel_rfl K64.trace : K64.s9.aux.trace = K64.s1.aux.trace

def K64.ps : List Lin.Prm := [{ lo := 174763, hi := 349525 }]
def K64.V : List (Nat × Lin.Aff) := [(0, Lin.P 0)]

theorem K64.lin : Lin.goodLin K64.ps K64.V K64.O = true := by decide +kernel

/-- **Class `K64`.** -/
theorem K64.holds (F : Ffi) (x : F.S) (L : Nat) (h1 : 174763 ≤ L) (h2 : L ≤ 349525) :
    ∃ n t' C', (chunkStage F).Post L (chunkCall x) (chunkSrv L) t' C' ∧
      ∀ r, runC F n (under (chunkCall x) r) (chunkSrv L) = some (under t' r, C') := by
  have hg : Good (ρL L) K64.O :=
    Lin.goodLin_sound K64.lin (x := Lin.vx [(L : Int)]) (by simp only [K64.ps]; lin_mem) (by simp only [K64.V]; lin_mem [ρL])
  have hi : Inst (ρL L) K64.S1 (chunkSrv L) := by rw [K64.srv1]; exact chunk_inst L hg
  obtain ⟨_, hrun⟩ := tpl_sim K64.stage F x hi
  have hcall : chunkCall x = tpl K64.s1 0 x [] := by
    unfold chunkCall; rw [K64.call]
  have hc : chunkC L = 64 := by
    rw [chunkC_eq L (by omega)]
    repeat' split
    all_goals omega
  refine ⟨34230, tpl K64.s9 0 x [], ⟨K64.S9.tab.map (SymE.eval (ρL L))⟩, ⟨?_, .num (.lit (.fin false 64 0)), K64.ret, ?_⟩, ?_⟩
  · rw [hcall]
    exact framed_of F x K64.heapEq K64.nextLe K64.small K64.jobs K64.stores K64.trace
  · rw [hc]; rfl
  · intro r; rw [hcall]; exact hrun r

/-! ## The contract -/

/-- **The `chunkSize` stage holds**: for every FFI, native state and caller stack, the call returns
`chunkC L` and changes nothing else. -/
theorem chunkStage_holds (F : Ffi) : (chunkStage F).Holds := by
  rintro (L : Nat) t Cs ⟨h1, h2, ⟨x, rfl⟩, rfl⟩
  by_cases a : L ≤ 8
  · exact K8.holds F x L h1 a
  by_cases b : L ≤ 10922
  · exact K2048.holds F x L (by omega) b
  by_cases c : L ≤ 21845
  · exact K1024.holds F x L (by omega) c
  by_cases d : L ≤ 43690
  · exact K512.holds F x L (by omega) d
  by_cases e : L ≤ 87381
  · exact K256.holds F x L (by omega) e
  by_cases f : L ≤ 174762
  · exact K128.holds F x L (by omega) f
  · exact K64.holds F x L (by omega) h2

end Host.Ts.Sim.Stage.ChunkSize
