// coefficient of restitution for particle-to-wall collisions.
const epsilonWall = 0.7;
const epsilonParticle = 0.6;

// max stable gravity, about 600.
const baseGravity = 600;

// lowest size that doesn't break really easily, 8.5.
const r = 9.7;
// max stable amount: 10/11
const balls = 9;

// damping to make everything less springy
const unconfinedPositionDamping = 0.9;
const unconfinedVelocityDamping = 0.9; // prev: 0.87
const confinedVelocityDamping = 0.89; // prev: 84
const overallVelocityDamping = 0.995;

const overlapTolerancePerRadius = 0; // prev: 0.0004

// make this any odd number. Even numbers are very weird about the
// boundary cases (ie walls), which I don't even begin to understand.
const resolvePenetrationIterations = 5;
