// coefficient of restitution for particle-to-wall collisions.
const epsilonWall = 0.15;
const epsilonParticle = 0.7;

const baseGravity = 300.0;

// lowest size that doesn't break really easily, 8ish.
const r = 11;
// max stable amount: 10
const balls = 8;

const confinedCircleDampening = 0.95;
const overlapTolerancePerRadius = 0; //.0004;

// make this any odd number. Even numbers are very weird about the
// boundary cases (ie walls), which I don't even begin to understand.
const resolvePenetrationIterations = 5;
