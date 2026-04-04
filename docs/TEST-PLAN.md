# Pinball Bounce Test Plan

## Quality Strategy
Hyper-casual games live and die by their "feel". Testing focuses on framerate stability and ad network implementation.

## Scenarios
- **Ad Flow:** Verify game pauses completely when an ad opens and resumes gracefully when closed.
- **Memory Leaks:** For Arcade games, ensure restarting a level 50 times does not crash the device.
- **Mechanic Logic:** Validate High-velocity collision restitution (bounciness), flipper hinge physics.
