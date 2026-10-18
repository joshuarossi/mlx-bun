import host.mlx.NativeConvGeometry
import host.mlx.NativeFixedSliceGeometry

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- Checked constant metadata supplies both valuations of the original
convolution guard/formula. No target shape is postulated independently. -/
theorem ConvGeometry.constants (ν : Nat → F64) (stride padding dilation groups : Nat)
    (batch length channels outChannels kernel inChannels : Int)
    (inputExact : ExactDimensions [batch,length,channels])
    (weightExact : ExactDimensions [outChannels,kernel,inChannels])
    (outputExact : ExactDimensions [batch,convLength length kernel stride padding dilation,outChannels])
    (stridePositive : 0 < stride) (groupsPositive : 0 < groups) (channelGuard : channels = inChannels*groups) :
    ConvGeometry ν (constantShape [batch,length,channels]) (constantShape [outChannels,kernel,inChannels])
      (constantShape [batch,convLength length kernel stride padding dilation,outChannels]) stride padding dilation groups :=
  ⟨batch,length,channels,outChannels,kernel,inChannels,
    (LiteralDimensions.constants ν _ inputExact).literalValues,
    (LiteralDimensions.constants ν _ weightExact).literalValues,
    stridePositive,groupsPositive,channelGuard,LiteralDimensions.constants ν _ outputExact⟩

end Host.Mlx.Ffi.Annotated
