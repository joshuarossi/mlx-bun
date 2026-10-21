import host.sim.template.clear.Shift
import host.sim.template.FactsGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The facts of case `CLEAR` the loop induction consumes (`LoopCase`, apart from the
checked run): the token reference, the end counters, freshness of `var 17`, the
substitution, the end control, the framed arrays' growth, and the counter deltas. -/

kernel_rfl CLEAR.num79 : CLEAR.σ.num 79 = .ref CLEAR.S150.tab.length
kernel_rfl CLEAR.hE_check : Nat.blt CLEAR.s150.ffi.mlx.next 131072 = true
theorem CLEAR.hE : CLEAR.s150.ffi.mlx.next < 131072 := Nat.le_of_ble_eq_true CLEAR.hE_check
kernel_rfl CLEAR.noVarTab_check : CLEAR.S150.tab.all (SymE.noVar 17) = true
kernel_rfl CLEAR.noVarOr_check : CLEAR.S150.oracle.all (Ans.noVar 17) = true
theorem CLEAR.noVarTab : ∀ e ∈ CLEAR.S150.tab, e.noVar 17 = true := List.all_eq_true.mp CLEAR.noVarTab_check
theorem CLEAR.noVarOr : ∀ q ∈ CLEAR.S150.oracle, q.noVar 17 = true := List.all_eq_true.mp CLEAR.noVarOr_check
kernel_rfl CLEAR.theta_low : (List.range 18).all (fun j => decide (CLEAR.θ j = loopTheta false 17 j)) = true
kernel_rfl CLEAR.theta_keys : CLEAR.R.theta.all (fun p => Nat.blt p.1 18) = true
theorem CLEAR.theta : ∀ j, CLEAR.θ j = loopTheta false 17 j := theta_eq CLEAR.theta_low CLEAR.theta_keys
kernel_rfl CLEAR.ctl_check : notRetB CLEAR.s150.ctl = true
theorem CLEAR.ctl_notRet : ∀ v, CLEAR.s150.ctl ≠ .ret v := notRet_of CLEAR.ctl_check

/-- The forwarded array's appended elements. -/
noncomputable def CLEAR.xs : List Val := (arrOf CLEAR.s150 2673447).drop (arrOf Base.s0 2673447).length
kernel_rfl CLEAR.xs_eq : CLEAR.xs = [.num (.ref 79)]
kernel_rfl CLEAR.fwd_get : CLEAR.s150.heap.get 2673447 = some (.obj (objOf CLEAR.s150 2673447))
kernel_rfl CLEAR.fwd_kind : (objOf CLEAR.s150 2673447).kind = .array (arrOf Base.s0 2673447 ++ CLEAR.xs)
kernel_rfl CLEAR.emit_get : CLEAR.s150.heap.get 12502 = some (.obj (objOf CLEAR.s150 12502))
kernel_rfl CLEAR.emit_kind : (objOf CLEAR.s150 12502).kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79)])
theorem CLEAR.fwd : ∃ o, CLEAR.s150.heap.get 2673447 = some (.obj o) ∧ o.kind = .array (arrOf Base.s0 2673447 ++ CLEAR.xs) :=
  ⟨_, CLEAR.fwd_get, CLEAR.fwd_kind⟩
theorem CLEAR.emit : ∃ o, CLEAR.s150.heap.get 12502 = some (.obj o) ∧ o.kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79)]) :=
  ⟨_, CLEAR.emit_get, CLEAR.emit_kind⟩
kernel_rfl CLEAR.fix_check : loopFix.all (fun a => Nat.beq (CLEAR.σ.a a) a) = true
theorem CLEAR.fix : ∀ a ∈ loopFix, CLEAR.σ.a a = a := fun a ha => by
  have := List.all_eq_true.mp CLEAR.fix_check a ha
  simpa using this

-- counters and their per-iteration deltas
kernel_rfl CLEAR.dJ : CLEAR.s150.next - Base.s0.next = 147918
kernel_rfl CLEAR.dH : CLEAR.s150.ffi.mlx.next - Base.s0.ffi.mlx.next = 3642
kernel_rfl CLEAR.dN : CLEAR.s150.ffi.mlx.nnext - Base.s0.ffi.mlx.nnext = 2381

end Host.Load.Run.Tpl
