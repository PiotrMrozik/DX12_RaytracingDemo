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

// #DXR Custom: Simple Lighting
// Raytracing acceleration structure, accessed as a SRV
RaytracingAccelerationStructure SceneBVH : register(t2);

[shader("closesthit")]
void ReflectionClosestHit(inout ReflectionHitInfo payload, Attributes attrib)
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
    
    float3 worldOrigin = WorldRayOrigin() + RayTCurrent() * WorldRayDirection();
    
    float3 vectToLight = LIGHT_POS - worldOrigin;
    float3 distToLight = length(vectToLight);
    float3 lightDir = normalize(vectToLight);
    
    // #DXR Custom: Simple Lighting
    float3 ambient = AMBIENT_FACTOR * LIGHT_COL;
    
    float diff = max(dot(normal, lightDir), 0.0f);
    float3 diffuse = diff * LIGHT_COL;
    
    float3 reflectDir = reflect(-lightDir, normal);
    float3 viewDir = normalize(-WorldRayDirection());
    float3 spec = pow(max(dot(viewDir, reflectDir), 0.0f), SHININESS);
    float3 specular = SPECULAR_FACTOR * spec * LIGHT_COL;
    
    RayDesc ray;
    ray.Origin = worldOrigin;
    ray.Direction = lightDir;
    ray.TMin = MIN_SECONDARY_RAY_T;
    ray.TMax = distToLight;
    bool hit = true;
    
    // Initialize the ray payload
    ShadowHitInfo shadowPayload;
    shadowPayload.isHit = false;
    
    // Trace the ray
    TraceRay(
    // Acceleration structure
    SceneBVH,
    // Flags can be used to specify the behavior upon hitting a surface
    RAY_FLAG_NONE,
    // Instance inclusion mask
    0xFF,
    // Depending on the type of ray, a given object can have several hit
    // groups attached (ie. what to do when hitting to compute regular
    // shading, and what to do when hitting to compute shadows). Those hit
    // groups are specified sequentially in the SBT, so the value below
    // indicates which offset (on 4 bits) to apply to the hit groups for this
    // ray. In this sample we now have two hit groups per object, where second
    // hit group is for shadow rays, hence an offset of 1.
    1,
    // The offsets in the SBT can be computed from the object ID, its instance
    // ID, but also simply by the order the objects have been pushed in the
    // acceleration structure. This allows the application to group shaders in
    // the SBT in the same order as they are added in the AS, in which case
    // the value below represents the stride (4 bits representing the number
    // of hit groups) between two consecutive objects.
    0,
    // Index of the miss shader: shadow miss shader
    1,
    // Ray information to trace
    ray,
    // Payload associated to the ray, which will be used to communicate
    // between the hit/miss shaders and the raygen
    shadowPayload);
    
    // #DXR Custom: Simple Lighting
    float diffFactor = shadowPayload.isHit ? 0.0f : 1.0f;
    
    float3 objectColor = BTriVertex[indices[vertId + 0]].color * barycentrics.x +
                         BTriVertex[indices[vertId + 1]].color * barycentrics.y +
                         BTriVertex[indices[vertId + 2]].color * barycentrics.z;
    
    // #DXR Custom: Simple Lighting
    float3 hitColor = (ambient + diffFactor * (diffuse + specular)) * objectColor;
    
	
    payload.colorAndDistance = float4(hitColor, RayTCurrent());
    payload.normalAndIsHit = float4(normal, 1.0f);
}

[shader("miss")]
void ReflectionMiss(inout ReflectionHitInfo hit : SV_RayPayload)
{
    hit.colorAndDistance = float4(SKY_COL, -1.0f);
    hit.normalAndIsHit = float4(0.0f, 0.0f, 0.0f, 0.0f);
}