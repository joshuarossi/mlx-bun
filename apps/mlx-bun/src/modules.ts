import type { AppModule } from "@mlx-bun/app-core";

// The one file that names module packages: import each `@mlx-bun/module-<id>`
// here and list it, and add it to package.json's dependencies. Order is
// activation order. No feature has moved into a module yet.
export const modules: readonly AppModule[] = [];
