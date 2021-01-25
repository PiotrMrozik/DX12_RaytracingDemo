#include "Common.hlsl"

// #DXR Extra: Another Ray Type

[shader("closesthit")]
void ShadowClosestHit(inout ShadowHitInfo hit, Attributes bary)
{
    hit.isHit = true;
}

[shader("miss")]
void ShadowMiss(inout ShadowHitInfo hit : SV_RayPayload)
{
    hit.isHit = false;
}