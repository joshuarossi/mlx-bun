import host.ts.RenameRouteFields
import host.ts.renameOrdinary.DriverArithmetic
import host.ts.renameOrdinary.NativeBufferCase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

def ShapeArgumentTail (stack : List Frame) : Prop :=
  ∃ (fn this ptr : Val) (env : Env) (rest : List Frame),
    stack = .c (.args 0 fn this [natV 0,ptr] [] env) :: rest

theorem literal_zero : FirstLiteral.sourceValue = natV 0 := by host_kernel_rfl
theorem argument3_kind : Structural3.sourceKind = 0 := by host_kernel_rfl
theorem argument3_rest : Structural3.sourceRest = [.expr Structural4.descent.whole] := by host_kernel_rfl
theorem argument3_acc : Structural3.sourceAcc = [.ptr (.ext 117452) 0] := by host_kernel_rfl

theorem literal_four : Literal7.sourceValue = natV 4 := by host_kernel_rfl
theorem binary_operator_mul : Structural6.sourceOp = .mul := by host_kernel_rfl
/-- A fixed rank cell supplies the occurrence annotation used by the real shape
byte-length arithmetic. The prefix derives literal operands rather than
recovering their roles from the unannotated numeric relation. -/
theorem first_eight_rank_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3)))) :
    ∃ result, runC P.F 8 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        P.RestStream.micro0.micro0.s8 result ∧
      result.ctl = .ret (natV 4) ∧
      ∃ fs, result.stack = .e (.binR .mul (natV 3)) :: fs ∧ ShapeArgumentTail fs := by
  obtain ⟨v0,hr0,h1,_⟩ := FirstVariable.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s h
  let s1 := s.ret v0
  obtain ⟨s2,hr1,h2⟩ := Structural1.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s1 h1
  obtain ⟨hr2,h3,_,_⟩ := FirstLiteral.transport FR R ν₀ ν C₀ C live framed before after old old' s2 h2
  let s3 := s2.ret FirstLiteral.sourceValue
  obtain ⟨s4,hr3,h4⟩ := Structural3.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s3 h3
  obtain ⟨s5,hr4,h5⟩ := Structural4.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s4 h4
  have hh2 := step_argument_heap_from_source P.F (NumberRoles ν₀ ν C₀ C) FR R live framed
    before after old old' Structural1.input s1 s2 C C h1 Structural1.sourceValue Structural1.sourceKind
    Structural1.sourceFunction Structural1.sourceThis Structural1.sourceAcc Structural1.sourceRest
    Structural1.sourceEnv Structural1.sourceTail Structural1.source_control Structural1.source_frame (by decide) hr1
  have hh4 := step_argument_heap_from_source P.F (NumberRoles ν₀ ν C₀ C) FR R live framed
    before after old old' Structural3.input s3 s4 C C h3 Structural3.sourceValue Structural3.sourceKind
    Structural3.sourceFunction Structural3.sourceThis Structural3.sourceAcc Structural3.sourceRest
    Structural3.sourceEnv Structural3.sourceTail Structural3.source_control Structural3.source_frame (by decide) hr3
  have hh5 := step_descent_heap_from_source P.F (NumberRoles ν₀ ν C₀ C) FR R live framed
    before after old old' Structural4.input s4 s5 C C h4 Structural4.descent Structural4.sourceEnv
    Structural4.source_control hr4
  have hc5 := (h5.control_view Variable5.source_control).ev_view
  have he5 : lookupEnv Variable5.sourceName (R.env Variable5.sourceEnv) = some (R.a Variable5.address) := by
    rw [lookupEnv_map,Variable5.source_lookup]
    rfl
  have hv5 : s5.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))) := by
    have hh5s : s5.heap = s.heap := by
      calc
        s5.heap = s4.heap := hh5
        _ = s3.heap := hh4
        _ = s2.heap := rfl
        _ = s1.heap := hh2
        _ = s.heap := rfl
    rw [hh5s]
    exact rank
  obtain ⟨v5,hr5,h6,_⟩ := Variable5.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s5 h5
  have hr5fixed : interpC (step P.F s5).run C = some (s5.ret (natV 3),C) := by
    rw [step_variable_eq P.F s5 Variable5.sourceName (R.env Variable5.sourceEnv)
      (R.a Variable5.address) (natV 3) hc5 he5 hv5]
    rfl
  have hval5 : v5 = natV 3 := by
    have hp := congrArg (fun p : St P.F.S × CSrv => p.1.ctl) (Option.some.inj (hr5fixed.symm.trans hr5))
    exact (Ctl.ret.inj hp).symm
  subst v5
  let s6 := s5.ret (natV 3)
  obtain ⟨s7,hr6,h7⟩ := Structural6.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s6 h6
  obtain ⟨hr7,h8,_,_⟩ := Literal7.transport FR R ν₀ ν C₀ C live framed before after old old' s7 h7
  let result := s7.ret Literal7.sourceValue
  obtain ⟨f3,fs3,hf3,hfr3,_⟩ := h3.stack_view Structural3.source_frame
  obtain ⟨fn3,this3,acc3,hframe3,_,_,hacc3⟩ := hfr3.args_view
  rw [hframe3] at hf3
  rw [argument3_acc] at hacc3
  obtain ⟨ptr3,hacc3eq⟩ : ∃ ptr3, acc3 = [ptr3] := by
    cases hacc3 with | cons hv hs => cases hs; exact ⟨_,rfl⟩
  have hr3fixed : interpC (step P.F s3).run C = some
      (argumentState {s3 with stack := fs3} Structural3.sourceKind fn3 this3
        (FirstLiteral.sourceValue::acc3) Structural3.sourceRest (R.env Structural3.sourceEnv),C) := by
    rw [step_argument_eq P.F s3 FirstLiteral.sourceValue Structural3.sourceKind fn3 this3 acc3
      Structural3.sourceRest (R.env Structural3.sourceEnv) fs3 rfl hf3 (by decide)]
    rfl
  have hs4 := congrArg Prod.fst (Option.some.inj (hr3fixed.symm.trans hr3))
  dsimp only at hs4
  have hstack4 : s4.stack = .c (.args 0 fn3 this3 [natV 0,ptr3] [] (R.env Structural3.sourceEnv))::fs3 := by
    have hh := congrArg St.stack hs4
    rw [argument3_kind,argument3_rest,hacc3eq,literal_zero] at hh
    exact hh.symm
  have hc4 := (h4.control_view Structural4.source_control).ev_view
  have hr4fixed : interpC (step P.F s4).run C = some
      ((s4.push (Structural4.descent.frame (R.env Structural4.sourceEnv))).go
        (.ev Structural4.descent.focus (R.env Structural4.sourceEnv)),C) := by
    rw [step_descent_eq P.F s4 Structural4.descent (R.env Structural4.sourceEnv) hc4]
    rfl
  have hs5 := congrArg Prod.fst (Option.some.inj (hr4fixed.symm.trans hr4))
  dsimp only at hs5
  have hstack5 : s5.stack = Structural4.descent.frame (R.env Structural4.sourceEnv)::s4.stack :=
    (congrArg St.stack hs5).symm
  obtain ⟨f6,fs6,hf6,hfr6,_⟩ := h6.stack_view Structural6.source_frame
  rw [hfr6.binL_view] at hf6
  have hr6fixed := step_binary_left_eq P.F s6 (natV 3) Structural6.sourceOp Structural6.sourceRight
    (R.env Structural6.sourceEnv) fs6 rfl hf6
  have hr6original := hr6
  change interpC (step P.F s6).run C = some (s7,C) at hr6
  rw [hr6fixed] at hr6
  have hs7 := congrArg Prod.fst (Option.some.inj hr6)
  dsimp only at hs7
  have htail6 : fs6 = s4.stack := by
    have ht := congrArg List.tail hf6
    have hd := congrArg List.tail hstack5
    change s5.stack.tail = fs6 at ht
    change s5.stack.tail = s4.stack at hd
    exact ht.symm.trans hd
  refine ⟨result,?_,h8,?_,fs6,?_,?_⟩
  case refine_4 => exact ⟨fn3,this3,ptr3,R.env Structural3.sourceEnv,fs3,htail6.trans hstack4⟩
  case refine_2 => exact congrArg Ctl.ret literal_four
  case refine_3 =>
    change s7.stack = .e (.binR .mul (natV 3)) :: fs6
    have hh := congrArg St.stack hs7
    change .e (.binR Structural6.sourceOp (natV 3)) :: fs6 = s7.stack at hh
    rw [binary_operator_mul] at hh
    exact hh.symm
  apply runC_cons P.F 7 s s1 result C C C (h.control.isHalt_eq.trans source_active0) hr0
  apply runC_cons P.F 6 s1 s2 result C C C (h1.control.isHalt_eq.trans source_active1) hr1
  apply runC_cons P.F 5 s2 s3 result C C C (h2.control.isHalt_eq.trans source_active2) hr2
  apply runC_cons P.F 4 s3 s4 result C C C (h3.control.isHalt_eq.trans source_active3) hr3
  apply runC_cons P.F 3 s4 s5 result C C C (h4.control.isHalt_eq.trans source_active4) hr4
  apply runC_cons P.F 2 s5 s6 result C C C (h5.control.isHalt_eq.trans source_active5) hr5
  apply runC_cons P.F 1 s6 s7 result C C C (h6.control.isHalt_eq.trans source_active6) hr6original
  apply runC_cons P.F 0 s7 result result C C C (h7.control.isHalt_eq.trans source_active7) hr7
  rfl

/-- With the fixed rank occurrence, the actual numeric primitive folds to the
literal byte count12 and leaves the target server unchanged. -/
theorem first_nine_rank_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3)))) :
    ∃ result, runC P.F 9 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        P.RestStream.micro0.micro0.s9 result ∧ result.ctl = .ret (natV 12) ∧ ShapeArgumentTail result.stack := by
  obtain ⟨s8,hr8,h8,hc8,fs8,hf8,hshape8⟩ := first_eight_rank_transport FR R ν₀ ν C₀ C
    live framed before after old old' s h rank
  have hr9fixed : interpC (step P.F s8).run C = some ({s8 with stack := fs8}.ret (natV 12),C) := by
    rw [step_arithmetic_eq P.F s8 .mul (.lit (F64.ofNat 3)) (.lit (F64.ofNat 4)) fs8 hc8 hf8]
    host_kernel_rfl
  obtain ⟨s9,D,hr9,h9,_⟩ := Arithmetic8.transport FR R ν₀ ν C₀ C live framed before after old old' s8 h8
  have hp := Option.some.inj (hr9fixed.symm.trans hr9)
  have hd := congrArg Prod.snd hp
  dsimp only at hd
  subst D
  have hs := congrArg Prod.fst hp
  dsimp only at hs
  have one : runC P.F 1 s8 C = some (s9,C) :=
    runC_cons P.F 0 s8 s9 s9 C C C (h8.control.isHalt_eq.trans source_active8) hr9 rfl
  refine ⟨s9,runC_join P.F hr8 one,h9,(congrArg St.ctl hs).symm,?_⟩
  have hh : fs8 = s9.stack := congrArg St.stack hs
  exact hh ▸ hshape8


/-- The argument continuation retains both literal offset0 and literal count12.
These are derived from the executed AST literals and fixed rank cell. -/
theorem first_ten_rank_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3)))) :
    ∃ result, runC P.F 10 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        P.RestStream.micro0.micro0.s10 result ∧
      (Annotated.Value.literal (.lit (F64.ofNat 0))).Holds ν C R (callArgument result.ctl 1) ∧
      (Annotated.Value.literal (.lit (F64.ofNat 12))).Holds ν C R (callArgument result.ctl 2) := by
  obtain ⟨s9,hr9,h9,hc9,fn,this,ptr,env,fs,hf9⟩ := first_nine_rank_transport FR R ν₀ ν C₀ C
    live framed before after old old' s h rank
  have hr10fixed : interpC (step P.F s9).run C =
      some ({s9 with stack := fs}.go (.call fn this [ptr,natV 0,natV 12]),C) := by
    rw [step_argument_eq P.F s9 (natV 12) 0 fn this [natV 0,ptr] [] env fs hc9 hf9 (by decide)]
    rfl
  obtain ⟨s10,hr10,h10⟩ := Structural9.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s9 h9
  have hs10 := congrArg Prod.fst (Option.some.inj (hr10fixed.symm.trans hr10))
  dsimp only at hs10
  have hc10 : s10.ctl = .call fn this [ptr,natV 0,natV 12] := (congrArg St.ctl hs10).symm
  have one : runC P.F 1 s9 C = some (s10,C) :=
    runC_cons P.F 0 s9 s10 s10 C C C (h9.control.isHalt_eq.trans source_active9) hr10 rfl
  refine ⟨s10,runC_join P.F hr9 one,h10,?_,?_⟩
  · rw [hc10]
    exact .literal _ _ rfl
  · rw [hc10]
    exact .literal _ _ rfl

theorem source_active10 : isHalt P.RestStream.micro0.micro0.s10.ctl = false := by host_kernel_rfl

theorem source_buffer_next : P.RestStream.micro0.micro0.s0.next = NativeBuffer.input.next := by host_kernel_rfl

/-- A complete actual eleven-step host block, including Bun's real native
buffer allocation. The decoder roles are proved by the preceding prefix;
only the initial rank annotation and resource/prototype invariants remain. -/
theorem first_eleven_rank_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))))
    (hp : live aArrayBufferProto) (hpr : R.a aArrayBufferProto = aArrayBufferProto)
    (ht : s.next < 2^64) :
    ∃ result, runC P.F 11 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live NativeBuffer.input.next)
        framed before after old old' NativeBuffer.output result := by
  obtain ⟨s10,hr10,h10,hoff,hcount⟩ := first_ten_rank_transport FR R ν₀ ν C₀ C
    live framed before after old old' s h rank
  have hnext : s10.next = s.next := by
    have hstart := h.heap.fresh 0
    have hend := h10.heap.fresh 0
    simp only [Nat.add_zero] at hstart hend
    rw [source_buffer_next] at hstart
    exact hend.symm.trans hstart
  obtain ⟨s11,hr11,h11⟩ := NativeBuffer.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C ν live framed
    before after old old' s10 h10 hoff hcount hp hpr (hnext ▸ ht)
  have hh : isHalt s10.ctl = false := h10.control.isHalt_eq.trans source_active10
  have one : runC P.F 1 s10 C = some (s11,C) := runC_cons P.F 0 s10 s11 s11 C C C hh hr11 rfl
  exact ⟨s11,runC_join P.F hr10 one,h11⟩


host_transport_structural P.F, P.RestStream.micro0.micro0.s11 to P.RestStream.micro0.micro0.s12 as Structural11

theorem source_active11 : isHalt P.RestStream.micro0.micro0.s11.ctl = false := by host_kernel_rfl

/-- Include the actual ordinary constructor-argument continuation between
native buffer allocation and typed-view construction. -/
theorem first_twelve_rank_transport (FR : Ren → P.F.S → P.F.S → Prop)
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s)
    (rank : s.heap.get (R.a Variable5.address) = some (.cell (some (natV 3))))
    (hp : live aArrayBufferProto) (hpr : R.a aArrayBufferProto = aArrayBufferProto)
    (ht : s.next < 2^64) :
    ∃ result, runC P.F 12 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live NativeBuffer.input.next)
        framed before after old old' P.RestStream.micro0.micro0.s12 result := by
  obtain ⟨s11,hr11,h11⟩ := first_eleven_rank_transport FR R ν₀ ν C₀ C live framed
    before after old old' s h rank hp hpr ht
  obtain ⟨s12,hr12,h12⟩ := Structural11.transport (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    (LiveAfter live NativeBuffer.input.next) framed before after old old' s11 h11
  have one : runC P.F 1 s11 C = some (s12,C) := runC_cons P.F 0 s11 s12 s12 C C C
    (h11.control.isHalt_eq.trans source_active11) hr12 rfl
  exact ⟨s12,runC_join P.F hr11 one,h12⟩

end Host.Load.Run.Full.Ordinary
