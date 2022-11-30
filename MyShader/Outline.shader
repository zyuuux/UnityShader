// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Outline"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _OutlineWidth ("Outline Width", Float) = 1.0
        _DiffuseColor ("Diffuse Color", Color) = (1, 1, 1, 1)
		_OutlineColor ("Outline Color", Color) = (1, 1, 1, 1) 
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _OutlineWidth;
            fixed4 _OutlineColor;

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

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				float2 offset = TransformViewToProjection(vnormal.xy);
				o.pos.xy += offset * _OutlineWidth;  //向法线方向扩展
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }

            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            fixed4 _DiffuseColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, unity_WorldToObject);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _DiffuseColor;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = UnityWorldSpaceLightDir(i.pos);
                fixed3 lambert = 0.5 + dot(worldNormal, lightDir) * 0.5;
                fixed3 diffuse = lambert * _DiffuseColor.xyz * _LightColor0.xyz + ambient;
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = col.rgb * diffuse;
                return col;
            }
            ENDCG
        }
    }
}
