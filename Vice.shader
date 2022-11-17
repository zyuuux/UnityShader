Shader "Vice"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Grow ("Grow", Range(-1, 1.5)) = 0.0
        _GrowMin ("Grow Min", Range(0, 1.0)) = 0.6
        _GrowMax ("Grow Max", Range(0, 1.5)) = 1.35
        _EndMin ("End Min", Range(0, 1.0)) = 0.0
        _EndMax ("End Max", Range(0, 1.5)) = 1.0
        _Expand ("Expand", Float) = 0.0
        _Scale ("Scale", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Grow;  //控制生长
            float _GrowMin;
            float _GrowMax;
            float _EndMin;
            float _EndMax;
            float _Expand;
            float _Scale;

            v2f vert (appdata v)
            {
                v2f o;
                float weight_expand = smoothstep(_GrowMin, _GrowMax, (v.texcoord.y - _Grow));  //收缩权重，控制衰减范围
                float weight_end = smoothstep(_EndMin, _EndMax, v.texcoord.y);  //保持末端收缩不变
                float weight_combined = max(weight_expand, weight_end);  //控制整体收缩权重
                float3 vertex_offset = v.normal * _Expand * 0.01f * weight_combined;  //整体变小
                float3 vertex_scale = v.normal * _Scale * 0.01f;  //整体变大
                float3 final_offset = vertex_offset + vertex_scale;
                v.vertex.xyz = v.vertex.xyz + final_offset;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(1.0 - (i.uv.y - _Grow));
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
