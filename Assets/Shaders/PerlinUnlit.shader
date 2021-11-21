Shader "Unlit/Perlin"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
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
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;

                v2f vert(appdata v)
                {
                    v2f o;

                    float frequency = 1;
                    float amplitude = 1;
                    float noiseHeight = 0;

                    for (int i = 0; i < _Octaves; i++)
                    {
                        float xValue = (v.vertex.x / _NoiseScale) * frequency;
                        float zValue = (v.vertex.z / _NoiseScale) * frequency;

                        float noiseSample = (ClassicNoise(float2(xValue + _WidthOffset, zValue + _HeightOffset)) * 2) - 1;

                        noiseHeight += noiseSample * amplitude;
                        frequency *= _Lacunarity;
                        amplitude *= _Persistence;
                    }

                    v.vertex.y = noiseHeight * _VerticalScale;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    UNITY_TRANSFER_FOG(o,o.vertex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    // sample the texture
                    fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
