# Luau type checking

Cmdr's Luau source uses `--!strict` and shared type contracts from `CmdrClient/Shared/Types`.

## Enable the new type solver

Strict checking and the new type solver are separate Workspace settings in Roblox Studio. Open the experience's **Workspace** properties and set:

- **Luau Type Check Mode** to **Strict**.
- **Use New Luau Type Solver** to **Enabled**.

These are Studio/editor settings, not scriptable properties; a package module cannot enable them at runtime. Save the place after changing them so collaborators using the place receive the same setting.

The command/type extension points intentionally accept dynamically parsed argument values: custom command arguments can parse into different Roblox data types. Those values are marked as dynamic at the API boundary, while the command, registry, dispatcher, hooks, and argument-context shapes are described by exported types.
