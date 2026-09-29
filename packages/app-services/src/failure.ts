import type { ModelHostError, ResidencyFailure } from "@mlx-bun/app-core";

export class ModelHostFailure extends Error implements ModelHostError {
  constructor(readonly code: ResidencyFailure, message: string, options?: { cause?: unknown }) {
    super(message, options);
    this.name = "ModelHostFailure";
  }
}
