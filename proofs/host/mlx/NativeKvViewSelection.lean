import host.mlx.NativeKvViewGeometry

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated

/-- Source-only eligibility for a four-dimensional KV prefix view. Rank alone
cannot distinguish it from a static query/gate split on the width dimension. -/
def kvPrefixEligible (input first last strides : List Int) : Bool :=
  match input,last with
  | [b,h,c,d],[b',h',used,d'] =>
      decide (first = [0,0,0,0] ∧ strides = [1,1,1,1] ∧
        b' = b ∧ h' = h ∧ d' = d ∧ 0 ≤ b ∧ 0 ≤ h ∧ 0 ≤ used ∧ 0 ≤ d ∧ used ≤ c)
  | _,_ => false

theorem kvPrefixEligible_four (b h c d b' h' used d' : Int) (first strides : List Int) :
    kvPrefixEligible [b,h,c,d] first [b',h',used,d'] strides =
      decide (first = [0,0,0,0] ∧ strides = [1,1,1,1] ∧
        b' = b ∧ h' = h ∧ d' = d ∧ 0 ≤ b ∧ 0 ≤ h ∧ 0 ≤ used ∧ 0 ≤ d ∧ used ≤ c) := rfl

theorem strict_prefix_selected : kvPrefixEligible [1,4,256,256] [0,0,0,0] [1,4,4,256] [1,1,1,1] = true := rfl

theorem full_capacity_selected : kvPrefixEligible [1,4,256,256] [0,0,0,0] [1,4,256,256] [1,1,1,1] = true := rfl

theorem grown_prefix_selected : kvPrefixEligible [1,4,512,256] [0,0,0,0] [1,4,257,256] [1,1,1,1] = true := rfl

theorem query_width_split_rejected : kvPrefixEligible [1,1,24,512] [0,0,0,0] [1,1,24,256] [1,1,1,1] = false := rfl

theorem gate_width_split_rejected : kvPrefixEligible [1,1,24,512] [0,0,0,256] [1,1,24,512] [1,1,1,1] = false := rfl

theorem capacity_overrun_rejected : kvPrefixEligible [1,4,256,256] [0,0,0,0] [1,4,257,256] [1,1,1,1] = false := rfl

theorem rank_three_rejected : kvPrefixEligible [1,4,10240] [0,1,0] [1,4,10240] [1,1,1] = false := rfl

end Host.Mlx.Ffi.Annotated
