Shader "Scan"
{
    Properties
    {
        _MainTex("Main Tex", 2D) = "White" {}
        _RimMin("RimMin", Range(-1, 1)) = 0.0
        _RimMax("RimMax", Range(0, 2)) = 1.0
        _TexPower("Tex Power", Range(0, 5)) = 5.0
        _InnerColor("Inner Color", Color) = (1, 1, 1, 1)
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimIntensity("Rim Intensity", Float) = 1.0
        _FlowTilling("Flow Tilling", Vector) = (1, 1, 1, 0)
        _FlowSpeed("Flow Speed", vector) = (1, 1, 1, 0)
        _FlowTex("Flow Tex", 2D) = "White" {}
        _FlowIntensity("Flow Intensity", Range(0, 5)) = 0.5
        _InnerAlpha("Inner Alpha", Range(-1, 1)) = 0.0
     }

    SubShader
    {
        Tags { "Queue" = "Transparent" }

        Pass
        {  
            ZWrite off
            Blend SrcAlpha One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {   
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {   
                float4 pos : SV_POSITION; 
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldPivot : TEXCOORD3;
            };

            sampler2D _MainTex;
            float _RimMin;
            float _RimMax;
            float _TexPower;
            float4 _InnerColor;
            float4 _RimColor;
            float _RimIntensity;
            float4 _FlowTilling;
            float4 _FlowSpeed;
            sampler2D _FlowTex;
            float _FlowIntensity;
            float _InnerAlpha;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = mul(float4(v.normal, 0), unity_WorldToObject).xyz;
                o.worldPivot = mul(unity_ObjectToWorld, float4(0, 0, 0, 1.0)).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 worldNormal = normalize(i.worldNormal);
                half3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
               
                //菲涅尔
                half NdotV = saturate(dot(worldNormal, worldView));
                half fresnel = 1.0 - NdotV;
                fresnel = smoothstep(_RimMin, _RimMax, fresnel);

                //材质的alpha值
                fixed4 emiss = tex2D(_MainTex, i.uv).r;
                emiss = pow(emiss, _TexPower);

                half finalRimAlpha = saturate(fresnel + emiss);
                half3 finalRimColor = lerp(_InnerColor.xyz, _RimColor.xyz * _RimIntensity, finalRimAlpha);

                //流光
                half2 flowUV = (i.worldPos.xy - i.worldPivot.xy) * _FlowTilling.xy;
                flowUV = flowUV + _Time.y * _FlowSpeed.xy;
                float4 flowColor = tex2D(_FlowTex, flowUV) * _FlowIntensity;

                float3 finalColor = finalRimColor + flowColor.xyz;
                float finalAlpha = saturate(finalRimAlpha + flowColor.a + _InnerAlpha);
                return fixed4(finalColor, finalAlpha);
            }

            ENDCG
        }
    }
}
