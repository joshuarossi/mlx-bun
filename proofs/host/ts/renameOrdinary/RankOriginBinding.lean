import host.ts.renameOrdinary.RankOriginNative
import host.ts.RenameRouteArgumentFields
import host.ts.RenameRoutePrivateFields
import host.ts.RenameRouteReturnFields
import host.ts.RenameRouteDriverReturns
import host.ts.RenameRouteDriverBinding
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
host_transport_structural P.F, P.micro3275.s2 to P.micro3275.s3 as Collect2
host_transport_return P.F, P.micro3275.s4 to P.micro3275.s5 as Return4
host_transport_return P.F, P.micro3275.s5 to P.micro3275.s6 as Return5
host_transport_return P.F, P.micro3275.s6 to P.micro3275.s7 as Return6
host_transport_return P.F, P.micro3275.s7 to P.micro3275.s8 as Return7
host_transport_binding P.F, P.micro3275.s8 to P.micro3275.s9 as Declare8
host_transport_binding P.F, P.micro3275.s9 to P.micro3275.s10 as Initialize9

noncomputable def numberInput : St LSt := P.micro3275.s3
noncomputable def numberAddress : Nat := match numberInput.ctl with
  | .call (.obj a) _ _ => a | _ => 0
noncomputable def numberReceiver : Val := match numberInput.ctl with
  | .call _ this _ => this | _ => .undef
noncomputable def numberObject : Obj := match numberInput.heap.get numberAddress with
  | some (.obj o) => o | _ => ⟨.ordinary,.null,[],[],true⟩
theorem number_control : numberInput.ctl = .call (.obj numberAddress) numberReceiver [.big (Int.ofNat 3)] := by host_kernel_rfl
theorem number_heap : numberInput.heap.get numberAddress = some (.obj numberObject) := by host_kernel_rfl
theorem number_kind : numberObject.kind = .fn (.native (.num .number) []) := by host_kernel_rfl
theorem number_post : numberInput.ret (intV (Int.ofNat 3)) = P.micro3275.s4 := by host_kernel_rfl

/-- The real native rank call, Number conversion, returns and lexical binding
initialize the actual shape getter's rank cell with literal three. -/
theorem initialize_rank_framed (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R NodeRel ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (shape : ∀ i n n', NodeRel i n n' → Host.Mlx.Ffi.Parametric.ShapeR (NumberRoles ν₀ ν C₀ C) n.shape n'.shape)
    (signatureFrame : ¬ framed signature) (handleLive : H 29363)
    (handleRole : (Annotated.Value.handle 29363).Holds ν C R (callArgument s.ctl 0))
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.micro3275.s10 result ∧
      result.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))) ∧
      (∀ a, a ≠ R.a Variable5.address → result.heap.get a = s.heap.get a) := by
  let NR := NumberRoles ν₀ ν C₀ C
  obtain ⟨s2,hr1,h2,hc2,hh2⟩ := transport_fields NR FR R C₀ C ν live framed before after old old' s h
    NodeRel ObjRel H N tail native shape signatureFrame handleLive handleRole
  obtain ⟨s3,hr2,h3⟩ := Collect2.transport NR FR R C₀ C live framed before after old old' s2 h2
  have hf2 : Collect2.input.stack = .c (.args 0 Collect2.sourceFunction Collect2.sourceThis
      Collect2.sourceAcc [] Collect2.sourceEnv)::Collect2.sourceTail := by host_kernel_rfl
  have hl2 : Collect2.sourceAcc.length = 0 := by host_kernel_rfl
  have argument : callArgument s3.ctl 0 = .big (Int.ofNat 3) := by
    have ha := step_argument_last P.F NR FR R live framed before after old old' Collect2.input s2 s3 C C h2
      Collect2.sourceValue (.big (Int.ofNat 3)) Collect2.sourceFunction Collect2.sourceThis
      Collect2.sourceAcc Collect2.sourceEnv Collect2.sourceTail Collect2.source_control hc2 hf2 hr2
    simpa only [hl2] using ha
  have integerRole : (Annotated.Value.ordinaryBig (Int.ofNat 3)).Holds ν C R (callArgument s3.ctl 0) :=
    argument.symm ▸ Annotated.Value.Holds.ordinaryBig (Int.ofNat 3)
  obtain ⟨_,hr3,h4raw⟩ := step_number_integer_from_source Host.Load.ffi FR R ν₀ ν C₀ C live framed before after old old'
    numberInput s3 h3 numberAddress numberObject [] numberReceiver (Int.ofNat 3)
    number_control number_heap number_kind integerRole
  have h4 : StateR NR FR R live framed before after old old' P.micro3275.s4 (s3.ret (intV (Int.ofNat 3))) :=
    number_post ▸ h4raw
  let s4 := s3.ret (intV (Int.ofNat 3))
  have hi : intV (Int.ofNat 3) = natV 3 := by host_kernel_rfl
  have hc4 : s4.ctl = .ret (natV 3) := congrArg Ctl.ret hi
  obtain ⟨s5,hr4,h5⟩ := Return4.transport NR FR R C₀ C live framed before after old old' s4 h4
  have hc5 : s5.ctl = .abr (.ret (natV 3)) := step_return_exit_control P.F NR FR R live framed
    before after old old' Return4.input s4 s5 C C h4 (natV 3) Return4.sourceAction Return4.sourceEnv
    Return4.sourceTail Return4.source_frame hc4 hr4
  obtain ⟨s6,hr5,h6⟩ := Return5.transport NR FR R C₀ C live framed before after old old' s5 h5
  have hc6 : s6.ctl = .abr (.ret (natV 3)) := step_return_unwind_control P.F NR FR R live framed
    before after old old' Return5.input s5 s6 C C h5 (natV 3) Return5.sourceAction Return5.sourceEnv
    Return5.sourceTail Return5.source_frame hc5 hr5
  obtain ⟨s7,hr6,h7⟩ := Return6.transport NR FR R C₀ C live framed before after old old' s6 h6
  have hc7 : s7.ctl = .abr (.ret (natV 3)) := step_return_unwind_control P.F NR FR R live framed
    before after old old' Return6.input s6 s7 C C h6 (natV 3) Return6.sourceAction Return6.sourceEnv
    Return6.sourceTail Return6.source_frame hc6 hr6
  obtain ⟨s8,hr7,h8⟩ := Return7.transport NR FR R C₀ C live framed before after old old' s7 h7
  have hc8 : s8.ctl = .ret (natV 3) := step_return_unwind_control P.F NR FR R live framed
    before after old old' Return7.input s7 s8 C C h7 (natV 3) Return7.sourceAction Return7.sourceEnv
    Return7.sourceTail Return7.source_frame hc7 hr7
  obtain ⟨s9,hr8,h9⟩ := Declare8.transport NR FR R C₀ C live framed before after old old' s8 h8
  have hc9 := step_declaration_control P.F NR FR R live framed before after old old' Declare8.input s8 s9 C C h8
    (natV 3) Declare8.sourceKind Declare8.sourcePattern Declare8.sourceRest Declare8.sourceEnv
    Declare8.sourceTail Declare8.source_frame hc8 Declare8.source_kind hr8
  have hpat : Declare8.sourcePattern = .id Initialize9.sourceName := by host_kernel_rfl
  have henv : Declare8.sourceEnv = Initialize9.sourceEnv := by host_kernel_rfl
  have hkind : Declare8.sourceKind = Initialize9.sourceKind := by host_kernel_rfl
  rw [hpat,henv,hkind] at hc9
  have hn9 : s9.next = s.next := h.target_next_eq h9 (by host_kernel_rfl)
  have hb9 : s9.next ≤ 2^64 := hn9 ▸ bound
  obtain ⟨result,hr9,h10⟩ := Initialize9.transport NR FR R C₀ C live framed before after old old' s9 h9 hb9
  have hlookup : lookupEnv Initialize9.sourceName (R.env Initialize9.sourceEnv) =
      some (R.a Initialize9.sourceAddress) := by rw [lookupEnv_map,Initialize9.source_lookup]; rfl
  have fixedRun : interpC (step P.F s9).run C =
      some (((s9.setCell (R.a Initialize9.sourceAddress) (natV 3)).ret .undef),C) := by
    rw [step_bind_init_eq P.F s9 Initialize9.sourceName (natV 3) (R.env Initialize9.sourceEnv)
      Initialize9.sourceKind (R.a Initialize9.sourceAddress) hc9 hlookup]
    rfl
  have he := congrArg Prod.fst (Option.some.inj (hr9.symm.trans fixedRun))
  dsimp only at he
  have ha : live Initialize9.sourceAddress := by
    have hl := h9.controlLive
    change treeSupport live (Encode.ctl Initialize9.input.ctl) at hl
    rw [Initialize9.source_control] at hl
    exact env_lookup_live _ _ _ hl.2.2.1 Initialize9.source_lookup
  have haddress : R.a Initialize9.sourceAddress < 2^64 := Nat.lt_of_lt_of_le (h9.heap.targetBound _ ha) hb9
  have hcell : result.heap.get (R.a Initialize9.sourceAddress) = some (.cell (some (natV 3))) := by
    rw [he]
    simp only [St.ret,St.setCell,PTrie.get_set_u64 _ _ _ haddress,ite_true]
  have hsourceAddress : Initialize9.sourceAddress = Variable5.address := by host_kernel_rfl
  rw [hsourceAddress] at hcell
  have hh3 := step_argument_heap_from_source P.F NR FR R live framed before after old old' Collect2.input s2 s3 C C h2
    Collect2.sourceValue Collect2.sourceKind Collect2.sourceFunction Collect2.sourceThis Collect2.sourceAcc Collect2.sourceRest
    Collect2.sourceEnv Collect2.sourceTail Collect2.source_control Collect2.source_frame (by decide) hr2
  have hh5 := step_return_exit_heap P.F NR FR R live framed before after old old' Return4.input s4 s5 C C h4
    Return4.sourceValue Return4.sourceAction Return4.sourceEnv Return4.sourceTail Return4.source_control Return4.source_frame hr4
  have hh6 := step_return_unwind_heap P.F NR FR R live framed before after old old' Return5.input s5 s6 C C h5
    Return5.sourceValue Return5.sourceAction Return5.sourceEnv Return5.sourceTail Return5.source_control Return5.source_frame hr5
  have hh7 := step_return_unwind_heap P.F NR FR R live framed before after old old' Return6.input s6 s7 C C h6
    Return6.sourceValue Return6.sourceAction Return6.sourceEnv Return6.sourceTail Return6.source_control Return6.source_frame hr6
  have hh8 := step_return_unwind_heap P.F NR FR R live framed before after old old' Return7.input s7 s8 C C h7
    Return7.sourceValue Return7.sourceAction Return7.sourceEnv Return7.sourceTail Return7.source_control Return7.source_frame hr7
  have hh9 := step_declaration_value_heap P.F NR FR R live framed before after old old' Declare8.input s8 s9 C C h8
    Declare8.sourceValue Declare8.sourceKind Declare8.sourcePattern Declare8.sourceRest Declare8.sourceEnv Declare8.sourceTail
    Declare8.source_control Declare8.source_frame Declare8.source_kind hr8
  have heap9 : s9.heap = s.heap := hh9.trans (hh8.trans (hh7.trans (hh6.trans (hh5.trans (hh3.trans hh2)))))
  have frame : ∀ a, a ≠ R.a Variable5.address → result.heap.get a = s.heap.get a := by
    intro a ha
    have ha' : a ≠ R.a Initialize9.sourceAddress := hsourceAddress.symm ▸ ha
    rw [he]
    simp only [St.ret,St.setCell,PTrie.get_set_u64 _ _ _ haddress,ite_eq_right ha']
    rw [heap9]
  refine ⟨result,?_,h10,hcell,frame⟩
  apply runC_cons P.F 8 s s2 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr1
  apply runC_cons P.F 7 s2 s3 result C C C (h2.control.isHalt_eq.trans (by host_kernel_rfl)) hr2
  apply runC_cons P.F 6 s3 s4 result C C C (h3.control.isHalt_eq.trans (by host_kernel_rfl)) hr3
  apply runC_cons P.F 5 s4 s5 result C C C (h4.control.isHalt_eq.trans (by host_kernel_rfl)) hr4
  apply runC_cons P.F 4 s5 s6 result C C C (h5.control.isHalt_eq.trans (by host_kernel_rfl)) hr5
  apply runC_cons P.F 3 s6 s7 result C C C (h6.control.isHalt_eq.trans (by host_kernel_rfl)) hr6
  apply runC_cons P.F 2 s7 s8 result C C C (h7.control.isHalt_eq.trans (by host_kernel_rfl)) hr7
  apply runC_cons P.F 1 s8 s9 result C C C (h8.control.isHalt_eq.trans (by host_kernel_rfl)) hr8
  apply runC_cons P.F 0 s9 result result C C C (h9.control.isHalt_eq.trans (by host_kernel_rfl)) hr9
  rfl

theorem initialize_rank (FR : Ren → LSt → LSt → Prop) (R : Ren) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s : St LSt) (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (NodeRel : Nat → Host.Mlx.Ffi.Node → Host.Mlx.Ffi.Node → Prop)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R NodeRel ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (shape : ∀ i n n', NodeRel i n n' → Host.Mlx.Ffi.Parametric.ShapeR (NumberRoles ν₀ ν C₀ C) n.shape n'.shape)
    (signatureFrame : ¬ framed signature) (handleLive : H 29363)
    (handleRole : (Annotated.Value.handle 29363).Holds ν C R (callArgument s.ctl 0))
    (bound : s.next ≤ 2^64) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.micro3275.s10 result ∧
      result.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))) := by
  obtain ⟨result,hr,hs,rank,_⟩ := initialize_rank_framed FR R ν₀ ν C₀ C live framed before after old old' s h
    NodeRel ObjRel H N tail native shape signatureFrame handleLive handleRole bound
  exact ⟨result,hr,hs,rank⟩
end Host.Load.Run.Full.Ordinary.RankOrigin
