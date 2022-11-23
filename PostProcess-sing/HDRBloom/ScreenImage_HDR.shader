Shader "ScreenImage_HDR"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 screen_pos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_HDR;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                //o.screen_pos = o.pos;
                //o.screen_pos.y = o.pos.y * _ProjectionParams.x;
                o.screen_pos = ComputeScreenPos(o.pos);  //处理跨平台引起的坐标系差异问题
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 screen_uv = i.screen_pos.xy / (i.screen_pos.w + 0.000001);  //透视除法
                //screen_uv = (screen_uv + 1.0) * 0.5;
                half4 col = tex2D(_MainTex, screen_uv);
                col.rgb = DecodeHDR(col, _MainTex_HDR);
                return col;
            }
            ENDCG
        }
    }
}
