Shader "Custom/TerrainSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Enabled("Enabled", Int) = 0
        _FalloffEnabled("FalloffEnabled", Int) = 0
        [HideInInspector] _NoiseType("Noise type", Int) = 0
        [HideInInspector] _Width("Width", Int) = 10
        [HideInInspector] _Height("Height", Int) = 10
        [HideInInspector] _WidthOffset("Width offset", Float) = 0
        [HideInInspector] _HeightOffset("Height offset", Float) = 0
        [HideInInspector] _NoiseScale("Noise scale", Float) = 1
        [HideInInspector] _VerticalScale("Vertical scale", Float) = 1
        [HideInInspector] _Octaves("Octaves", Int) = 1
        [HideInInspector] _Lacunarity("Lacunarity", Float) = 50
        [HideInInspector] _Persistence("Persistence", Float) = 0.5
    }
    SubShader
    {
        

        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        #include "UnityCG.cginc"

        // https://github.com/keijiro/NoiseShader/blob/8de41c5f3e1e088eb032811470d8af9ed6861f1c/LICENSE
        #include "Packages/jp.keijiro.noiseshader/Shader/ClassicNoise2D.hlsl"
        #include "Packages/jp.keijiro.noiseshader/Shader/SimplexNoise2D.hlsl"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
            float3 customColor;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        int _Enabled;
        int _FalloffEnabled;
        int _NoiseType;
        int _Width;
        int _Height;
        float _WidthOffset;
        float _HeightOffset;
        float _NoiseScale;
        float _VerticalScale;
        float _Octaves;
        float _Lacunarity;
        float _Persistence;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float calculateNoiseHeight(int octaves, float x, float z)
        {
            float frequency = 1;
            float amplitude = 1;
            float noiseHeight = 0;

            for (int i = 0; i < _Octaves; i++)
            {
                float xValue = ((x + _WidthOffset) / _NoiseScale) * frequency;
                float zValue = ((z + _HeightOffset) / _NoiseScale) * frequency;

                float noiseSample = 0;

                if (_NoiseType == 0)
                {
                    noiseSample = (ClassicNoise(float2(xValue, zValue)) * 2) - 1;
                }
                else if (_NoiseType == 1)
                {
                    noiseSample = (SimplexNoise(float2(xValue, zValue)) * 2) - 1;
                }
                noiseHeight += abs(noiseSample) * amplitude;
                frequency *= _Lacunarity;
                amplitude *= _Persistence;
            }
            return noiseHeight;
        }

        float calculateFalloff(float x, float z) 
        {
            float falloffFactor = 1;
            if (_FalloffEnabled == 1)
            {
                falloffFactor = min(1, distance(float2(x % _Width, z % _Height), float2(0.5 * _Width, 0.5 * _Height)) / (0.5 * _Width));
                falloffFactor = -falloffFactor + 1;
            }
            return falloffFactor;
        }

        float calculateNoiseHeightWithFalloffandScale(int octaves, float x, float z)
        {
            return calculateNoiseHeight(octaves, x, z) * _VerticalScale * calculateFalloff(x, z);
        }

        

        float3 calculateNormalWithTangents(appdata_full v, float3 newPos)
        {
            float3 posPlusTangent = v.vertex + v.tangent * 0.01;
            posPlusTangent.y = calculateNoiseHeight(_Octaves, posPlusTangent.x, posPlusTangent.z);

            float3 bitangent = cross(v.normal, v.tangent);
            float3 posPlusBitangent = v.vertex + bitangent * 0.01;
            posPlusBitangent.y = calculateNoiseHeight(_Octaves, posPlusBitangent.x, posPlusBitangent.z);

            float3 modifiedTangent = posPlusTangent - newPos;
            float3 modifiedBitangent = posPlusBitangent - newPos;

            float3 modifiedNormal = cross(modifiedTangent, modifiedBitangent);

            return modifiedNormal;
        }

        float3 calculateNormalWithTangentsAverage(appdata_full v, float3 newPos)
        {
            float octaves = _Octaves;

            float3 topNewPos = float3(newPos.x, calculateNoiseHeightWithFalloffandScale(octaves, newPos.x, newPos.z + 1), newPos.z + 1);
            float3 topRightNewPos = float3(newPos.x + 1, calculateNoiseHeightWithFalloffandScale(octaves, newPos.x + 1, newPos.z + 1), newPos.z + 1);
            float3 rightNewPos = float3(newPos.x + 1, calculateNoiseHeightWithFalloffandScale(octaves, newPos.x + 1, newPos.z), newPos.z);
            float3 bottomNewPos = float3(newPos.x, calculateNoiseHeightWithFalloffandScale(octaves, newPos.x, newPos.z - 1), newPos.z - 1);
            float3 bottomLeftNewPos = float3(newPos.x - 1, calculateNoiseHeightWithFalloffandScale(octaves, newPos.x - 1, newPos.z - 1), newPos.z - 1);
            float3 leftNewPos = float3(newPos.x - 1, calculateNoiseHeightWithFalloffandScale(octaves, newPos.x - 1, newPos.z), newPos.z);

            float3 topRightLeftNormal = cross(topNewPos - newPos, topRightNewPos - newPos);
            float3 topRightRightNormal = cross(rightNewPos, topRightNewPos - newPos);
            float3 topLeftNormal = cross(topNewPos - newPos, leftNewPos - newPos);
            float3 bottomRightNormal = cross(bottomNewPos - newPos, rightNewPos - newPos);
            float3 bottomLeftLeftNormal = cross(bottomLeftNewPos - newPos, leftNewPos - newPos);
            float3 bottomLeftRightNormal = cross(bottomNewPos - newPos, bottomLeftNewPos - newPos);

            float3 modifiedNormal = normalize((topRightLeftNormal + topRightRightNormal + topLeftNormal + bottomRightNormal + bottomLeftLeftNormal + bottomLeftRightNormal) / 6);

            //return modifiedNormal;
            return normalize(topLeftNormal);
        }

        void vert(inout appdata_full v, out Input o) 
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            if (_Enabled == 1)
            {
                //float4 newPos = v.vertex + 0.01;
                float4 newPos = v.vertex;

                newPos.xyz += 1;

                float noiseHeight = calculateNoiseHeight(_Octaves, v.vertex.x, v.vertex.z);
                newPos.y = noiseHeight * _VerticalScale * calculateFalloff(v.vertex.x, v.vertex.z);

                float3 modifiedNormal = calculateNormalWithTangentsAverage(v, newPos);

                //TANGENT_SPACE_ROTATION;
                //v.normal = mul(rotation, modifiedNormal);
                v.normal = UnityObjectToWorldNormal(modifiedNormal);
                
                v.vertex = newPos;
                //o.customColor = abs(noiseHeight / 1.25);
                o.customColor = abs(v.normal) * 2;
            }
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
            o.Albedo *= IN.customColor;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
