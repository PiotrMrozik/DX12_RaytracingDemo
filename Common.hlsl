// Hit information, aka ray payload
// This sample only carries a shading color and hit distance.
// Note that the payload should be kept as small as possible,
// and that its size must be declared in the corresponding
// D3D12_RAYTRACING_SHADER_CONFIG pipeline subobject.
struct HitInfo
{
  float4 colorAndDistance;
};

// Attributes output by the raytracing when hitting a surface,
// here the barycentric coordinates
struct Attributes
{
  float2 bary;
};

struct ShadowHitInfo
{
    bool isHit;
};

struct ReflectionHitInfo
{
    float4 colorAndDistance;
    float4 normalAndIsHit;
};

struct STriVertex
{
    float3 vertex;
    float4 color;
};

static const float3 LIGHT_POS = float3(2.0f, 2.0f, -2.0f);
static const float3 LIGHT_COL = float3(1.0f, 1.0f, 1.0f);

static const float3 PLANE_COL = float3(0.7f, 0.7f, 0.3f);

static const float AMBIENT_FACTOR = 0.3f;