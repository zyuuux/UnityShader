Shader "MatCap"
{
    Properties
    {
        _MatCapTex ("MatCap Tex", 2D) = "white" {}
        _MatCapIntensity ("MatCap Intensity", Float) = 1.0      
        _MatCapAddTex ("MatCapAdd Tex", 2D) = "white" {}
        _MatCapAddIntensity ("MatCap Intensity", Float) = 1.0      
        _DiffuseTex ("Diffuse Tex", 2D) = "white" {}
        _RampTex ("Ramp Tex", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MatCapTex;
            float _MatCapIntensity;
            sampler2D _MatCapAddTex;
            float _MatCapAddIntensity;
            sampler2D _DiffuseTex;
            float4 _DiffuseTex_ST;
            sampler2D _RampTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
                o.worldNormal = mul(float4(v.normal, 0.0), unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //将法线从世界坐标转变为视口坐标
                half3 worldNormal = normalize(i.worldNormal);
                half3 viewNormal = mul(UNITY_MATRIX_V, float4(worldNormal, 0.0)).xyz;

                //base matCap
                half2 matCapUV = (viewNormal.xy + float2(1.0, 1.0)) * 0.5;
                half4 mapCapColor = tex2D(_MatCapTex, matCapUV) * _MatCapIntensity;

                half4 diffuseColor = tex2D(_DiffuseTex, i.uv);

                //Ramp
                half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half NdotV = saturate(dot(worldNormal, viewDir));
                half fresnel = 1.0 - NdotV;
                half2 rampUV = half2(fresnel, 0.5);
                half4 rampColor = tex2D(_RampTex, rampUV);

                //add matCap
                half4 mapCapAddColor = tex2D(_MatCapAddTex, matCapUV) * _MatCapAddIntensity;

                half4 finalColor = mapCapColor * diffuseColor * rampColor + mapCapAddColor;
                return finalColor;
            }

            ENDCG
        }
    }
}
