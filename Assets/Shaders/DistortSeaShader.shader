Shader "Unlit/ToonSeaShader"
{
    Properties
    {
        _SurfaceCutOffTex("SurfaceCutOff", 2D) = "white" {}
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.7
        _Speed("Speed", Range(0, 1)) = 0.7
        _NoiseAmount("NoiseAmount", Range(0, 1)) = 0.5
        _Tiling("Tiling", Range(0, 1)) = 0.5
        _NoiseTex("Noise", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" "RenderType"="Opaque"}
        LOD 100
        //Blend Zero SrcColor

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define SMOOTHSTEP_AA 0.02

            #pragma multi_compile_fwdbase
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                LIGHTING_COORDS(0,1)
            };

            sampler2D _SurfaceCutOffTex;
            float _SurfaceNoiseCutoff;
            sampler2D _NoiseTex;
            fixed4 _Color;
            float _Speed;
            float _Tiling;
            float _NoiseAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uvNoise= 2 * tex2D(_NoiseTex, i.uv * _Tiling) - 1;
                i.uv.x += _Time.x * _Speed + uvNoise.x * _NoiseAmount;
                i.uv.y += _Time.x * _Speed + uvNoise.y * _NoiseAmount;
                float2 CutOffTex = tex2D(_SurfaceCutOffTex, i.uv * _Tiling );
                float surfaceNoise = smoothstep(_SurfaceNoiseCutoff - SMOOTHSTEP_AA, _SurfaceNoiseCutoff + SMOOTHSTEP_AA, CutOffTex.r);
                fixed4 col = _Color + surfaceNoise;
                float attenuation = LIGHT_ATTENUATION(i);
                return col* attenuation;
            }
            ENDCG
        }
    }
}
