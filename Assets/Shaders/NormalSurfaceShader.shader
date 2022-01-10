Shader "Custom/CalculateNormals"
{
    Properties{
     _MainTex("Texture", 2D) = "white" {}
    }
        SubShader{
          Tags { "RenderType" = "Opaque" }
          CGPROGRAM
          #pragma surface surf Lambert vertex:vert
          struct Input {
              float2 uv_MainTex;
              float3 customColor;
          };
          void vert(inout appdata_full v, out Input o) {
              UNITY_INITIALIZE_OUTPUT(Input,o);
              o.customColor = abs(v.normal);
          }
          sampler2D _MainTex;
          void surf(Input IN, inout SurfaceOutput o) {
              o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
              o.Albedo *= IN.customColor;
          }
          ENDCG
    }
        Fallback "Diffuse"
}
//    Properties
//    {
//        _Color("Color", Color) = (1,1,1,1)
//        _MainTex("Albedo (RGB)", 2D) = "white" {}
//        _Glossiness("Smoothness", Range(0,1)) = 0.5
//        _Metallic("Metallic", Range(0,1)) = 0.0
//
//        _PhaseOffset("Phase Offset", Float) = .1
//        _Speed("Speed", Float) = 1.5
//        _Depth("Depth", Float) = .14
//        _Smoothing("Smoothing", Range(.01, .9)) = .5
//        _XDrift("XDrift", Float) = .1
//        _ZDrift("ZDrift", Float) = .1
//        _Scale("Scale", Float) = 5
//
//        [Toggle(ENABLE_WORLD_SPACE)] _EnableWorldSpace("Enable World Space", Float) = 0
//    }
//        SubShader
//        {
//            Tags { "RenderType" = "Opaque" }
//            LOD 200
//
//            CGPROGRAM
//            // Physically based Standard lighting model, and enable shadows on all light types
//            #pragma surface surf Standard fullforwardshadows vertex:vert
//            #pragma shader_feature ENABLE_WORLD_SPACE
//
//
//            // Use shader model 3.0 target, to get nicer looking lighting
//            #pragma target 3.0
//
//            sampler2D _MainTex;
//
//            struct Input
//            {
//                float2 uv_MainTex;
//                float3 debugColor;
//            };
//
//            half _Glossiness;
//            half _Metallic;
//            fixed4 _Color;
//            float _PhaseOffset;
//            float _Speed;
//            float _Depth;
//            float _Smoothing;
//            float _XDrift;
//            float _ZDrift;
//            float _Scale;
//
//            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
//            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
//            // #pragma instancing_options assumeuniformscaling
//            UNITY_INSTANCING_BUFFER_START(Props)
//                // put more per-instance properties here
//            UNITY_INSTANCING_BUFFER_END(Props)
//
//            void vert(inout appdata_full v, out Input o)
//            {
//                UNITY_INITIALIZE_OUTPUT(Input, o);
//
//                #ifdef ENABLE_WORLD_SPACE
//                // Note that, to start off, all work is in object (local) space. // We will eventually move normals to world space to handle arbitrary object orientation. // There is no real need for tangent space in this case. 
//                // Do all work in world space 
//                float3 v0 = mul((float3x3)unity_ObjectToWorld, v.vertex).xyz;
//            #else
//                float3 v0 = v.vertex.xyz;
//            #endif
//
//                // Create two fake neighbor vertices. // The important thing is that they be distorted in the same way that a real vertex in their location would. 
//                // This is pretty easy since we're just going to do some trig based on position, so really any samples will do. 
//                float3 v1 = v0 + float3(0.05, 0, 0); //+X 
//                float3 v2 = v0 + float3(0, 0, 0.05); //+Z
//
//                // Some animation values 
//                float phase = _PhaseOffset * (3.14 * 2);
//                float phase2 = _PhaseOffset * (3.14 * 1.123);
//                float speed = _Time.y * _Speed;
//                float speed2 = _Time.y * (_Speed * 0.33);
//                float _Depth2 = _Depth * 1.0;
//                float v0alt = v0.x * _XDrift + v0.z * _ZDrift;
//                float v1alt = v1.x * _XDrift + v1.z * _ZDrift;
//                float v2alt = v2.x * _XDrift + v2.z * _ZDrift;
//
//                // Modify the real vertex and two theoretical samples by the distortion algorithm (here a simple sine wave on Y, driven by local X pos) 
//                v0.y += sin(phase + speed + (v0.x * _Scale)) * _Depth;
//                v0.y += sin(phase2 + speed2 + (v0alt * _Scale)) * _Depth2; // This is just another wave being applied for a bit more complexity. 
//
//                v1.y += sin(phase + speed + (v1.x * _Scale)) * _Depth;
//                v1.y += sin(phase2 + speed2 + (v1alt * _Scale)) * _Depth2;
//
//                v2.y += sin(phase + speed + (v2.x * _Scale)) * _Depth;
//                v2.y += sin(phase2 + speed2 + (v2alt * _Scale)) * _Depth2;
//
//                // By reducing the delta on Y, we effectively restrict the amout of variation the normals will exhibit. 
//                // This appears like a smoothing effect, separate from the actual displacement depth. 
//                // It's basically undoing the change to the normals, leaving them straight on Y. 
//                v1.y -= (v1.y - v0.y) * _Smoothing;
//                v2.y -= (v2.y - v0.y) * _Smoothing;
//
//                // Solve normal 
//                float3 vna = cross(v2 - v0, v1 - v0);
//
//                #ifdef ENABLE_WORLD_SPACE
//                // OPTIONAL worldspace normal out to a custom value. Uncomment the showNormals finalcolor profile option above to see the result 
//                //o.debugColor = ( normalize( vna ) * 0.5 ) + 0.5; //o.debugColor - ( normalize( vna ) ); 
//
//                // Put normals back in object space 
//                float3 vn = mul((float3x3)unity_WorldToObject, vna);
//
//                // Normalize 
//                v.normal = normalize(vn);
//            #else
//                //Normalize
//                v.normal = normalize(vna);
//            #endif
//                o.debugColor = v.normal;
//            #ifdef ENABLE_WORLD_SPACE
//                // Put vertex back in object space, Unity will automatically do the MVP projection 
//                v.vertex.xyz = mul((float3x3)unity_WorldToObject, v0);
//            #else
//                v.vertex.xyz = v0.xyz;
//            #endif
//        }
//
//        void surf(Input IN, inout SurfaceOutputStandard o)
//        {
//            // Albedo comes from a texture tinted by color
//            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
//            o.Albedo = IN.debugColor;
//            // Metallic and smoothness come from slider variables
//            o.Metallic = _Metallic;
//            o.Smoothness = _Glossiness;
//            o.Alpha = c.a;
//        }
//        ENDCG
//        }
//            FallBack "Diffuse"
//}