import { describe, expect, it } from "bun:test";
import { planExpertResidency } from "../../src/expert-residency";
import {
  GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES,
  planGlm52Memory,
  type Glm52MemoryGeometry,
} from "../../src/model/glm52-memory";

const productionGeometry: Glm52MemoryGeometry = {
  residentWeightBytes: 10_877_286_144,
  mainExpertSlotBytes: 18_939_904,
  mtpExpertSlotBytes: 37_814_272,
  hiddenSize: 6_144,
  vocabSize: 154_880,
  numHiddenLayers: 78,
  sparseLayers: 75,
  numAttentionHeads: 64,
  kvLoraRank: 512,
  qkRopeHeadDim: 64,
  qkHeadDim: 256,
  vHeadDim: 256,
  numRoutedExperts: 256,
  numExpertsPerToken: 8,
  dsaLayers: 0,
  dsaHeadDim: 128,
  mtpLayers: 1,
};

describe("GLM-5.2 G5 memory contract", () => {
  it("exposes the exact production-artifact 32 GB line items", () => {
    const plan = planGlm52Memory(productionGeometry);
    expect(plan).toMatchObject({
      preset: "g5-32gb-quality",
      processLimitBytes: 26_843_545_600,
      osReserveBytes: 7_516_192_768,
      contextTokens: 4096,
      maxGenerationTokens: 128,
      verifyRows: 4,
      mainWorkingSlots: 64,
      mainRequiredUnionSlots: 32,
      mainResidentSlots: 75,
      mainTotalSlots: 139,
      mtpWorkingSlots: 24,
      mtpResidentSlots: 1,
      mtpTotalSlots: 25,
      runtimeReserveBytes: 6_656_150_528,
      plannedProcessBytes: 21_111_440_128,
      processHeadroomBytes: 5_732_105_472,
    });
    expect(plan.lineItems).toEqual({
      residentWeightsBytes: 10_877_286_144,
      mainExpertSlabBytes: 2_632_646_656,
      mtpExpertSlabBytes: 945_356_800,
      targetKvBytes: 736_100_352,
      mtpKvBytes: 9_437_184,
      reconstructedKvTransientBytes: 537_395_200,
      verifyBatchTransientBytes: 4_508_672,
      allocatorReserveBytes: 4_294_967_296,
      bunNativeReserveBytes: 536_870_912,
      safetyMarginBytes: 536_870_912,
    });
    expect(plan).toMatchObject({
      strategy: "glm52-colibri",
      fits: true,
      maxSafeContext: plan.contextTokens,
      totalBytes: plan.plannedProcessBytes,
      usableBytes: plan.processLimitBytes,
      allocatorLimitBytes: plan.lineItems.allocatorReserveBytes,
    });
    expect(plan.weightsBytes + plan.kvBytes + plan.transientBytes + plan.reserveBytes)
      .toBe(plan.totalBytes);
    expect(plan.plannedMachineBytes + plan.machineHeadroomBytes)
      .toBe(plan.machineBytes);
  });

  it("is the same accounting equation used by expert startup", () => {
    const plan = planGlm52Memory(productionGeometry);
    const runtimePlan = planExpertResidency({
      budgetBytes: plan.processLimitBytes,
      fixedBytes:
        plan.lineItems.residentWeightsBytes +
        plan.runtimeReserveBytes +
        plan.lineItems.mtpExpertSlabBytes,
      slotBytes: productionGeometry.mainExpertSlotBytes,
      sparseLayers: productionGeometry.sparseLayers,
      workingSlots: plan.mainWorkingSlots,
      maxSlotsPerLayer: 1,
    });
    expect(runtimePlan.totalSlots).toBe(plan.mainTotalSlots);
    expect(runtimePlan.plannedBytes).toBe(plan.plannedProcessBytes);
  });

  it("removes every MTP-only allocation in the off lane", () => {
    const plan = planGlm52Memory({
      ...productionGeometry,
      residentWeightBytes: 10_592_313_856,
    }, {
      enableMtp: false,
    });
    expect(plan.enableMtp).toBe(false);
    expect(plan.verifyRows).toBe(1);
    expect(plan.mtpWorkingSlots).toBe(0);
    expect(plan.mtpTotalSlots).toBe(0);
    expect(plan.lineItems.mtpExpertSlabBytes).toBe(0);
    expect(plan.lineItems.mtpKvBytes).toBe(0);
    expect(plan.plannedProcessBytes).toBeLessThan(
      planGlm52Memory(productionGeometry).plannedProcessBytes,
    );
  });

  it("refuses impossible starts before weights are mapped", () => {
    expect(() => planGlm52Memory(productionGeometry, {
      processLimitBytes: 20_000_000_000,
    })).toThrow(/cannot start: planned .* exceed/);
    expect(() => planGlm52Memory(productionGeometry, {
      machineBytes: GLM52_G5_DEFAULT_PROCESS_LIMIT_BYTES - 1,
    })).toThrow(/process limit .* exceeds machine memory/);
    expect(() => planGlm52Memory(productionGeometry, {
      workingSlots: 31,
    })).toThrow(/verify-union slots exceed/);
    expect(() => planGlm52Memory(productionGeometry, {
      contextTokens: 64,
    })).toThrow(/generated tokens exceed/);
  });
});
