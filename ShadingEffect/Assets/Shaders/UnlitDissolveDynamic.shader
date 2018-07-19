Shader "Wrathlust/UnlitDissolveDynamic"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Dissolve Noise", 2D) = "white" {} // Texture the dissolve is based on
		_DisRadius ("Dissolve Radius", Range(0, 10)) = 0
		_DisWidth ("Dissolve Width", Range(0, 0.5)) = 0.05
		_DisColor ("Dissolve Color", Color) = (1, 1, 1, 1)
		_DisWidth2 ("Dissolve Width 2", Range(0, 0.5)) = 0.1
		_DisColor2 ("Dissolve Color 2", Color) = (1, 1, 1, 1)
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD1;
			};

			float3 _Position;

			sampler2D _MainTex;
			sampler2D _NoiseTex;
			float4 _MainTex_ST;

			float _DisRadius;
			float _DisWidth;
			float _DisWidth2;
			float4 _DisColor;
			float4 _DisColor2;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 noise = tex2D(_NoiseTex, i.uv).r;

				float dis = distance(_Position, i.worldPos);
				dis += noise;
				//float sphereNoise = 1 - saturate(dis / _DisRadius);
				//sphereNoise = noise * sphereNoise;
				//dis += sphereNoise;

				float useDis2 = dis - _DisRadius < _DisWidth2;
				col = (1 - useDis2) * col + useDis2 * _DisColor2;
				
				float useDis = dis - _DisRadius < _DisWidth;
				col = (1 - useDis) * col + useDis * _DisColor;


				clip(dis - _DisRadius);

				return col;
			}
			ENDCG
		}
	}
}
