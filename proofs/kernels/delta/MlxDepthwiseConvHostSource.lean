import kernels.delta.Convolution
namespace Inference.Kernels.Delta.MlxDepthwiseConvHostSource
-- Reviewed conv.cpp dispatch translation. Descriptor construction, contiguous
-- preparation and native kernel lookup remain explicit host boundaries.
structure Descriptor where
  batch : Nat
  inputRows : Nat
  outputRows : Nat
  channels : Nat
  outputChannels : Nat
  groups : Nat
  kernel : Nat
  stride : Nat
  kernelDilation : Nat
  inputDilation : Nat
  padding : Nat
  flip : Bool
  inputSize : Nat
  dataSize : Nat
  deriving DecidableEq,Repr

def depthwise (d : Descriptor) : Bool :=
  Convolution.depthwiseSelected d.channels d.outputChannels d.groups d.stride
    d.kernelDilation d.inputDilation d.padding d.flip

def large (d : Descriptor) : Bool := d.inputSize>2147483647 || d.dataSize>2147483647

def selected : Descriptor := ⟨1,4,1,10240,10240,10240,4,1,1,1,0,false,40960,40960⟩
def grid (d : Descriptor) : Nat×Nat×Nat := ⟨d.channels,d.outputRows,d.batch⟩
def strides : Nat×Nat×Nat := ⟨40960,10240,1⟩

theorem selected_dispatch : depthwise selected=true ∧ large selected=false ∧
    grid selected=(10240,1,1) ∧ selected.kernel=4 ∧ strides=(40960,10240,1) := by decide +kernel

theorem complete_thread (channel : Fin 10240) :
    channel.val<(grid selected).1 := channel.isLt

-- dispatch_threads launches exactly one live thread per output channel; the
-- native block-dimension policy does not alter this logical global grid.
theorem grid_owner (x y z : Nat) (hx : x<10240) (hy : y<1) (hz : z<1) :
    ∃ channel : Fin 10240,x=channel.val ∧ y=0 ∧ z=0 := by
  exact ⟨⟨x,hx⟩,rfl,by omega,by omega⟩
end Inference.Kernels.Delta.MlxDepthwiseConvHostSource
