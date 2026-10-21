import host.sim.template.ordinary.Shift
import host.sim.template.FactsGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The facts of case `ORDINARY` the loop induction consumes (`LoopCase`, apart from the
checked run): the token reference, the end counters, freshness of `var 17`, the
substitution, the end control, the framed arrays' growth, and the counter deltas. -/

kernel_rfl ORDINARY.num79 : ORDINARY.σ.num 79 = .ref ORDINARY.S150.tab.length
kernel_rfl ORDINARY.hE_check : Nat.blt ORDINARY.s150.ffi.mlx.next 131072 = true
theorem ORDINARY.hE : ORDINARY.s150.ffi.mlx.next < 131072 := Nat.le_of_ble_eq_true ORDINARY.hE_check
kernel_rfl ORDINARY.noVarTab_check : ORDINARY.S150.tab.all (SymE.noVar 17) = true
kernel_rfl ORDINARY.noVarOr_check : ORDINARY.S150.oracle.all (Ans.noVar 17) = true
theorem ORDINARY.noVarTab : ∀ e ∈ ORDINARY.S150.tab, e.noVar 17 = true := List.all_eq_true.mp ORDINARY.noVarTab_check
theorem ORDINARY.noVarOr : ∀ q ∈ ORDINARY.S150.oracle, q.noVar 17 = true := List.all_eq_true.mp ORDINARY.noVarOr_check
kernel_rfl ORDINARY.theta_low : (List.range 18).all (fun j => decide (ORDINARY.θ j = loopTheta false 17 j)) = true
kernel_rfl ORDINARY.theta_keys : ORDINARY.R.theta.all (fun p => Nat.blt p.1 18) = true
theorem ORDINARY.theta : ∀ j, ORDINARY.θ j = loopTheta false 17 j := theta_eq ORDINARY.theta_low ORDINARY.theta_keys
kernel_rfl ORDINARY.ctl_check : notRetB ORDINARY.s150.ctl = true
theorem ORDINARY.ctl_notRet : ∀ v, ORDINARY.s150.ctl ≠ .ret v := notRet_of ORDINARY.ctl_check

/-- The forwarded array's appended elements. -/
noncomputable def ORDINARY.xs : List Val := (arrOf ORDINARY.s150 2673447).drop (arrOf Base.s0 2673447).length
kernel_rfl ORDINARY.xs_eq : ORDINARY.xs = [.num (.ref 79)]
kernel_rfl ORDINARY.fwd_get : ORDINARY.s150.heap.get 2673447 = some (.obj (objOf ORDINARY.s150 2673447))
kernel_rfl ORDINARY.fwd_kind : (objOf ORDINARY.s150 2673447).kind = .array (arrOf Base.s0 2673447 ++ ORDINARY.xs)
kernel_rfl ORDINARY.emit_get : ORDINARY.s150.heap.get 12502 = some (.obj (objOf ORDINARY.s150 12502))
kernel_rfl ORDINARY.emit_kind : (objOf ORDINARY.s150 12502).kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79)])
theorem ORDINARY.fwd : ∃ o, ORDINARY.s150.heap.get 2673447 = some (.obj o) ∧ o.kind = .array (arrOf Base.s0 2673447 ++ ORDINARY.xs) :=
  ⟨_, ORDINARY.fwd_get, ORDINARY.fwd_kind⟩
theorem ORDINARY.emit : ∃ o, ORDINARY.s150.heap.get 12502 = some (.obj o) ∧ o.kind = .array (arrOf Base.s0 12502 ++ [.num (.ref 79)]) :=
  ⟨_, ORDINARY.emit_get, ORDINARY.emit_kind⟩
kernel_rfl ORDINARY.fix_check : loopFix.all (fun a => Nat.beq (ORDINARY.σ.a a) a) = true
theorem ORDINARY.fix : ∀ a ∈ loopFix, ORDINARY.σ.a a = a := fun a ha => by
  have := List.all_eq_true.mp ORDINARY.fix_check a ha
  simpa using this

-- counters and their per-iteration deltas
kernel_rfl ORDINARY.dJ : ORDINARY.s150.next - Base.s0.next = 147917
kernel_rfl ORDINARY.dH : ORDINARY.s150.ffi.mlx.next - Base.s0.ffi.mlx.next = 3642
kernel_rfl ORDINARY.dN : ORDINARY.s150.ffi.mlx.nnext - Base.s0.ffi.mlx.nnext = 2381

end Host.Load.Run.Tpl
