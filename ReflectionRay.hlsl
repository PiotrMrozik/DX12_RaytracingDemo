#include "Common.hlsl"

// #DXR Custom: Reflections
cbuffer Colors : register(b0)
{
    float3 A;
    float3 B;
    float3 C;
}
StructuredBuffer<STriVertex> BTriVertex : register(t0);
StructuredBuffer<int> indices : register(t1);

[shader("closesthit")]
void ReflectionClosestHit(inout ReflectionHitInfo hit, Attributes attrib)
{
    float3 barycentrics =
		float3(1.0f - attrib.bary.x - attrib.bary.y, attrib.bary.x, attrib.bary.y);

    uint vertId = 3 * PrimitiveIndex();
    
    float3x4 objectToWorld = ObjectToWorld();
    float3 v1 = mul(objectToWorld, BTriVertex[indices[vertId + 0]].vertex);
    float3 v2 = mul(objectToWorld, BTriVertex[indices[vertId + 1]].vertex);
    float3 v3 = mul(objectToWorld, BTriVertex[indices[vertId + 2]].vertex);
    
    float3 normal = normalize(cross((v2 - v3), (v1 - v2)));
    if (dot(normal, WorldRayDirection()) > 0.0f)
    {
        normal = -normal;
    }
    
    float3 hitColor = BTriVertex[indices[vertId + 0]].color * barycentrics.x +
                      BTriVertex[indices[vertId + 1]].color * barycentrics.y +
                      BTriVertex[indices[vertId + 2]].color * barycentrics.z;
    
	
    hit.colorAndDistance = float4(hitColor, RayTCurrent());
    hit.normalAndIsHit = float4(normal, 1.0f);
}

[shader("miss")]
void ReflectionMiss(inout ReflectionHitInfo hit : SV_RayPayload)
{
    hit.colorAndDistance = float4(0.0f, 0.2f, 0.7f, -1.0f);
    hit.normalAndIsHit = float4(0.0f, 0.0f, 0.0f, 0.0f);
}