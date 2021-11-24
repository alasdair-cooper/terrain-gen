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

        // https://github.com/keijiro/NoiseShader/blob/8de41c5f3e1e088eb032811470d8af9ed6861f1c/LICENSE
        #include "Packages/jp.keijiro.noiseshader/Shader/ClassicNoise2D.hlsl"
        #include "Packages/jp.keijiro.noiseshader/Shader/SimplexNoise2D.hlsl"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

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

        void vert(inout appdata_full v, out Input o) 
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            if (_Enabled == 1)
            {
                float falloffFactor = 1;

                if (_FalloffEnabled == 1)
                {
                    falloffFactor = min(1, distance(float2(v.vertex.x % _Width, v.vertex.z % _Height), float2(0.5 * _Width, 0.5 * _Height)) / (0.5 * _Width));
                    falloffFactor = -falloffFactor + 1;
                }

                float frequency = 1;
                float amplitude = 1;
                float noiseHeight = 0;

                for (int i = 0; i < _Octaves; i++)
                {
                    float xValue = ((v.vertex.x + _WidthOffset) / _NoiseScale) * frequency;
                    float zValue = ((v.vertex.z + _HeightOffset) / _NoiseScale) * frequency;

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
                v.vertex.y = noiseHeight * _VerticalScale * falloffFactor;
            }
            o.customColor = abs(v.normal);
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
