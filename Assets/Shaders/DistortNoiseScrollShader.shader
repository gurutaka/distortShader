Shader "Custom/DistortNoiseScrollShader"
{
    Properties
    {

        _MainTex("Main", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" {}
        _Speed("Speed", Range(0, 1)) = 0.7
        _NoiseAmount("NoiseAmount", Range(0, 0.05)) = 0.025
        _Brightness("Brightness", Range(1, 10)) = 5
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            fixed4 _Color;
            float _Speed;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float _NoiseAmount;
            float _Brightness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 nUv = i.uv;
                nUv.y += _Time.x * _Speed;
                float4 uvNoise= 2 * tex2D(_NoiseTex, nUv) -1 ;
                i.uv += uvNoise.xy * _NoiseAmount;
                fixed4 col = tex2D(_MainTex,i.uv);
                return col * _Color * _Brightness;
            }
            ENDCG
        }
    }
}
