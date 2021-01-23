#include "Common.hlsl"

// #DXR: Color by look-up in the vertex buffer (SRV)
struct STriVertex
{
    float3 vertex;
    float4 color;
};

// #DXR Extra: Per-Instance Data (Global Constant Buffer, Layout 2)
struct MyStructColor
{
    float4 a;
    float4 b;
    float4 c;
};

cbuffer Colors : register(b0)
{
    // #DXR Extra: Per-Instance Data (Global Constant Buffer, Layout 1)
    //float4 A[3];
    //float4 B[3];
    //float4 C[3];
    
    // #DXR Extra: Per-Instance Data (Global Constant Buffer, Layout 2)
    //MyStructColor Tint[3];
    
    // #DXR Extra: Per-Instance Data (Per-Instance Constant Buffer)
    float3 A;
    float3 B;
    float3 C;
}


StructuredBuffer<STriVertex> BTriVertex : register(t0);
StructuredBuffer<int> indices : register(t1);

[shader("closesthit")] 
void ClosestHit(inout HitInfo payload, Attributes attrib) 
{
	float3 barycentrics =
		float3(1.0f - attrib.bary.x - attrib.bary.y, attrib.bary.x, attrib.bary.y);

	uint vertId = 3 * PrimitiveIndex();
    
 //   float3 hitColor = BTriVertex[vertId + 0].color * barycentrics.x +
	//				  BTriVertex[vertId + 1].color * barycentrics.y +
	//				  BTriVertex[vertId + 2].color * barycentrics.z;
	
    //float3 A = float3(1.0f, 0.0f, 0.0f);
    //float3 B = float3(0.0f, 1.0f, 0.0f);
    //float3 C = float3(0.0f, 0.0f, 1.0f);
    
	// #DXR Extra: Per-Instance Data
    //float3 hitColor = float3(0.7f, 0.7f, 0.7f);

    // #DXR Extra: Per-Instance Data (Global Constant Buffer, Layout 2)
    //if (InstanceID() < 3)
    //{
    //    hitColor = Tint[InstanceID()].a * barycentrics.x + Tint[InstanceID()].b * barycentrics.y + Tint[InstanceID()].c * barycentrics.z;
    //}
    
    // #DXR Extra: Per-Instance Data (Per-Instance Constant Buffer)
    // hitColor = A * barycentrics.x + B * barycentrics.y + C * barycentrics.z;
    
    // #DXR Extra: Indexed Geometry
    float3 hitColor = BTriVertex[indices[vertId + 0]].color * barycentrics.x +
                      BTriVertex[indices[vertId + 1]].color * barycentrics.y +
                      BTriVertex[indices[vertId + 2]].color * barycentrics.z;
    
	
	payload.colorAndDistance = float4(hitColor, RayTCurrent());
}


// #DXR Extra: Per-Instance Data
[shader("closesthit")]
void PlaneClosestHit(inout HitInfo payload, Attributes attrib)
{
    float3 barycentrics =
        float3(1.0f - attrib.bary.x - attrib.bary.y, attrib.bary.x, attrib.bary.y);
    
    float3 hitColor = float3(0.7f, 0.7f, 0.3f);
    
    payload.colorAndDistance = float4(hitColor, RayTCurrent());

}