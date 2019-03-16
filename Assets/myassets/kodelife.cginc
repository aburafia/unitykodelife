#ifndef KODELIFE_INCLUDED
#define KODELIFE_INCLUDED

const float PI = 3.14159265359;

float2 uv2rect(float2 uv, float2 resolution)
{
    float2 p = uv * 2 - 1;
    p.x *= resolution.x / resolution.y;
    return p;
}

float2 uv2polar(float2 uv, float2 resolution)
{
    float2 p = uv * 2 - 1;
    p.x *= resolution.x / resolution.y;
    return float2(atan2(p.y, p.x) / PI / 2 + 0.5, length(p));
}

float2x2 rotate2d(float x)
{
	float sinx = sin(x);
	float cosx = cos(x);
    return float2x2(cosx, sinx, -sinx, cosx);
}

// 乱数生成
// http://neareal.net/index.php?ComputerGraphics%2FHLSL%2FCommon%2FGenerateRandomNoiseInPixelShader
float rnd(float2 value, int Seed=10)
{
    return frac(sin(dot(value.xy, float2(12.9898, 78.233)) + Seed) * 43758.5453);
}

float2 rnd2( float2 p ) {
    return frac(sin(float2(dot(p,float2(127.1,3.7)),dot(p,float2(269.5,183.3))))*43758.5453);
}



float fade(float x) { return x * x * x * (x * (x * 6 - 15) + 10); }
float2 fade(float2 x)  { return x * x * x * (x * (x * 6 - 15) + 10); }
float3 fade(float3 x) { return x * x * x * (x * (x * 6 - 15) + 10); }

float phash(float p)
{
    p = frac(7.8233139 * p);
    p = ((2384.2345 * p - 1324.3438) * p + 3884.2243) * p - 4921.2354;
    return frac(p) * 2 - 1;
}

float2 phash(float2 p)
{
    p = frac(mul(float2x2(1.2989833, 7.8233198, 6.7598192, 3.4857334) ,p));
    p = ((2384.2345 * p - 1324.3438) * p + 3884.2243) * p - 4921.2354;
    return normalize(frac(p) * 2 - 1);
}

float3 phash(float3 p)
{
    p = frac(mul(float3x3(1.2989833, 7.8233198, 2.3562332,
                   6.7598192, 3.4857334, 8.2837193,
                   2.9175399, 2.9884245, 5.4987265),p));
    p = ((2384.2345 * p - 1324.3438) * p + 3884.2243) * p - 4921.2354;
    return normalize(frac(p) * 2 - 1);
}

float cnoise(float p)
{
    float ip = floor(p);
    float fp = frac(p);
    float d0 = phash(ip    ) *  fp;
    float d1 = phash(ip + 1) * (fp - 1);
    return lerp(d0, d1, fade(fp));
}

float cnoise(float2 p)
{
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(phash(ip), fp);
    float d01 = dot(phash(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(phash(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(phash(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fade(fp);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

float cnoise(float3 p)
{
    float3 ip = floor(p);
    float3 fp = frac(p);
    float d000 = dot(phash(ip), fp);
    float d001 = dot(phash(ip + float3(0, 0, 1)), fp - float3(0, 0, 1));
    float d010 = dot(phash(ip + float3(0, 1, 0)), fp - float3(0, 1, 0));
    float d011 = dot(phash(ip + float3(0, 1, 1)), fp - float3(0, 1, 1));
    float d100 = dot(phash(ip + float3(1, 0, 0)), fp - float3(1, 0, 0));
    float d101 = dot(phash(ip + float3(1, 0, 1)), fp - float3(1, 0, 1));
    float d110 = dot(phash(ip + float3(1, 1, 0)), fp - float3(1, 1, 0));
    float d111 = dot(phash(ip + float3(1, 1, 1)), fp - float3(1, 1, 1));
    fp = fade(fp);
    return lerp(lerp(lerp(d000, d001, fp.z), lerp(d010, d011, fp.z), fp.y),
               lerp(lerp(d100, d101, fp.z), lerp(d110, d111, fp.z), fp.y), fp.x);
}

float noise (float2 st) {
    float2 i = floor(st);
    float2 f = frac(st);

    // Four corners in 2D of a tile
    float a = rnd(i);
    float b = rnd(i + float2(1.0, 0.0));
    float c = rnd(i + float2(0.0, 1.0));
    float d = rnd(i + float2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    float2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return lerp(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float3 rgb2hsv(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
 

float3 hsv2rgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#endif