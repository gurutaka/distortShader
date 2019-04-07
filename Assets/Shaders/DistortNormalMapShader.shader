Shader "Custom/DistortNormalMapShader"
{
    Properties
    {

        _Speed("Speed", Range(0, 1)) = 0.7
        _NormalMap ("Normal map", 2D) = "bump" {}
        _MainTex("Main", 2D) = "white" {}
        _DistortAmount("DistortAmount", Range(0, 0.05)) = 0.025
        _Shininess ("Shininess", Range(0.0, 1.0))  = 0.078125
        _Brightness("Brightness", Range(1, 10)) = 5
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define SMOOTHSTEP_AA 0.02

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 lightDir : TEXCOORD1;
                half3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            half4 _LightColor0;
            half _Shininess;
            float _Brightness;
            fixed4 _Color;
            float _Speed;
            float _DistortAmount;
            float _NoiseAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 nUv = i.uv;
                nUv.y += _Time.x * _Speed;
                i.lightDir = normalize(i.lightDir);
                i.viewDir = normalize(i.viewDir);
                half3 halfDir = normalize(i.lightDir + i.viewDir);

                // ノーマルマップから法線情報を取得する
                half3 normal = UnpackNormal(tex2D(_NormalMap, nUv * 0.5));
                i.uv.xy += normal * _DistortAmount;
                fixed4 col = tex2D(_MainTex,i.uv);

                half3 diffuse = max(0, dot(normal, i.lightDir)) * _LightColor0.rgb;
                half3 specular = pow(max(0, dot(normal, halfDir)), _Shininess * 128.0) * _LightColor0.rgb;
                col.rgb =col.rgb * diffuse * _Brightness + specular;
                return col * _Color;


            }
            ENDCG
        }
    }
}
