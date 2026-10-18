import host.ts.renameOrdinary.initialClosure.Groups0
import host.ts.renameOrdinary.initialClosure.Groups1
import host.ts.renameOrdinary.initialClosure.Groups2
import host.ts.renameOrdinary.initialClosure.Groups3
import host.ts.renameOrdinary.initialClosure.Groups4
import host.ts.renameOrdinary.initialClosure.Groups5
import host.ts.renameOrdinary.initialClosure.Groups6
import host.ts.renameOrdinary.initialClosure.Groups7
import host.ts.renameOrdinary.initialClosure.Groups8
import host.ts.renameOrdinary.initialClosure.Groups9
import host.ts.renameOrdinary.initialClosure.Groups10
import host.ts.renameOrdinary.initialClosure.Groups11
import host.ts.renameOrdinary.initialClosure.Groups12
import host.ts.renameOrdinary.initialClosure.Groups13
import host.ts.renameOrdinary.initialClosure.Groups14
import host.ts.renameOrdinary.initialClosure.Groups15
import host.ts.renameOrdinary.initialClosure.Groups16
import host.ts.renameOrdinary.initialClosure.Groups17
import host.ts.renameOrdinary.initialClosure.Groups18
import host.ts.renameOrdinary.initialClosure.Groups19
import host.ts.renameOrdinary.initialClosure.Groups20
import host.ts.renameOrdinary.initialClosure.Groups21
import host.ts.renameOrdinary.initialClosure.Groups22
import host.ts.renameOrdinary.initialClosure.Groups23
import host.ts.renameOrdinary.initialClosure.Facts
import host.ts.renameOrdinary.RankOriginBootPrefix

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitialClosure
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_closure_heap input,3126659,10 using Checked as heap_closed

theorem certificate : ClosureCheck.Certificate input 3126659 10 :=
  ⟨source_address_limit,heap_closed,control_closed,stack_closed,jobs_closed,stores_closed⟩

/-- The actual rank-entry heap is related to itself for every instantiated
number table. All runtime occurrence bounds are checked from that heap. -/
theorem identity_table (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.micro3275.S1.tab.map (SymE.eval ρ)) :
    Parametric.StateR (NumberRoles ρ ρ C C) (fun _ _ _ => True) Annotated.identity
      (· < input.next) (fun _ => False) [] [] input.trace input.trace input input := by
  apply certificate.identity ρ C
  simpa only [table,List.length_map,source_table_limit] using (Nat.le_refl 10)

theorem identity_inst (ρ : Nat → F64) (C : CSrv)
    (inst : Inst ρ (numberServer P.micro3275.S1) C) :
    Parametric.StateR (NumberRoles ρ ρ C C) (fun _ _ _ => True) Annotated.identity
      (· < input.next) (fun _ => False) [] [] input.trace input.trace input input :=
  identity_table ρ C inst.1

/-- The complete identity relation and literal captures hold at the actual
boot-reached source cut. Only the already consumed branch answers and the
ordinary initial symbolic-table instantiation are external to this prefix. -/
theorem source_initialization (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S0.tab.map (SymE.eval ρ)) (answers : Good ρ rankAnswers) :
    ∃ C', ((bootL Route.cx Decode.world 2000).bind fun start => runC Host.Load.ffi 32741797 start C) =
      some (input,C') ∧ C'.tab = P.micro3275.S1.tab.map (SymE.eval ρ) ∧
      Parametric.StateR (NumberRoles ρ ρ C' C') (fun _ _ _ => True) Annotated.identity
        (· < input.next) (fun _ => False) [] [] input.trace input.trace input input ∧
      NativeCaptureInventory (literalCaptures (· < input.next) input) ρ ρ C' C' Annotated.identity
        (· < input.next) input input := by
  obtain ⟨C',run,tab,captures⟩ := source_rank_initialization ρ C (· < input.next) table answers
  exact ⟨C',run,tab,identity_table ρ C' tab,captures⟩
end Host.Load.Run.Full.Ordinary.RankOrigin.InitialClosure
