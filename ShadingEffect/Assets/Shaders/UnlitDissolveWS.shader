Shader "Wrathlust/UnlitDissolveWorldSpace"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Dissolve Noise", 2D) = "white" {} // Texture the dissolve is based on
		_DisThreshold ("Dissolve Threshold", Range(0, 1)) = 0
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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			sampler2D _MainTex;
			sampler2D _NoiseTex;
			float4 _MainTex_ST;

			float _DisThreshold;
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
				o.worldNormal = mul(unity_ObjectToWorld, float4(v.normal, 0)).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal = normalize(i.worldNormal);

				float3 col1 = tex2D(_MainTex, i.worldPos.yz).rgb;
				float3 col2 = tex2D(_MainTex, i.worldPos.xz).rgb;
				float3 col3 = tex2D(_MainTex, i.worldPos.xy).rgb;

				float3 col21 = lerp(col2, col1, abs(worldNormal.x));
				float3 col213 = lerp(col21, col3, abs(worldNormal.z));
				
				//return float4(col213, 1);

				float3 noise1 = tex2D(_NoiseTex, i.worldPos.yz).rgb;
				float3 noise2 = tex2D(_NoiseTex, i.worldPos.xz).rgb;
				float3 noise3 = tex2D(_NoiseTex, i.worldPos.xy).rgb;

				float3 noise21 = lerp(noise2, noise1, abs(worldNormal.x));
				float3 noise213 = lerp(noise21, noise3, abs(worldNormal.z));

				fixed4 col = tex2D(_MainTex, i.uv);//fixed4(col213, 1);
				fixed4 noise = fixed4(noise213, 1);//tex2D(_NoiseTex, i.worldPos.xz).r;

				float useDis2 = noise - _DisThreshold < _DisWidth2;
				col = (1 - useDis2) * col + useDis2 * _DisColor2;
				
				float useDis = noise - _DisThreshold < _DisWidth;
				col = (1 - useDis) * col + useDis * _DisColor;

				clip(noise - _DisThreshold);

				return col;
			}
			ENDCG
		}
	}
}
