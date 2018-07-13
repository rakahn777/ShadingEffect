Shader "Wrathlust/UnlitDissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Dissolve Noise", 2D) = "white" {} // Texture the dissolve is based on
		_DisPercent ("Dissolve Percentage", Range(0, 1)) = 0
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
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _NoiseTex;
			float4 _MainTex_ST;

			float _DisPercent;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 noise = tex2D(_NoiseTex, i.uv).r;
				clip(noise - _DisPercent);
				return col;
			}
			ENDCG
		}
	}
}
