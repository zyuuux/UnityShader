Shader "WaterWave" 
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
	_WaveStrength ("Wave Strength", Float) = 0.01
	_WaveFactor ("Wave Factor", Float) = 50
	_TimeScale ("Time Scale", Float) = 10
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag

	    sampler2D _MainTex;
            float _WaveStrength;
            float _WaveFactor;
            float _TimeScale;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v) 
            {
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i):COLOR
            {                
		//计算出fixed2(0.5, 0.5)到uv每个点的单位向量方向
                fixed2 uvDir = normalize(i.uv - fixed2(0.5, 0.5));
		//计算出fixed2(0.5,0.5)到uv每个点的距离
                fixed dis = distance(i.uv, fixed2(0.5,0.5));
                fixed2 uv = i.uv + _WaveStrength * uvDir * sin(_Time.y * _TimeScale + dis * _WaveFactor);
                return tex2D(_MainTex, uv);
            }

            ENDCG
        }
    } 

    FallBack "Diffuse"
}

