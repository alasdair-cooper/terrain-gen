Shader "Unlit/Noise"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
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
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            // https://github.com/keijiro/NoiseShader/blob/8de41c5f3e1e088eb032811470d8af9ed6861f1c/LICENSE
            #include "Packages/jp.keijiro.noiseshader/Shader/ClassicNoise2D.hlsl"
            #include "Packages/jp.keijiro.noiseshader/Shader/SimplexNoise2D.hlsl"

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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                half3 worldNormal : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                if(_Enabled == 1)
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
                            noiseSample = (ClassicNoise(float2(xValue , zValue)) * 2) - 1;
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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = 0;
                col.rgb = i.worldNormal * 0.5 + 0.5;
                return col;
            }
            ENDCG
        }
    }
}