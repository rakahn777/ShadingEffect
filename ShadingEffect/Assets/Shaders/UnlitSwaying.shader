Shader "Wrathlust/UnlitSwaying"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_Speed ("MoveSpeed", Range(20,50)) = 25 // speed of the swaying
		_Rigidness("Rigidness", Range(1,50)) = 25 // lower makes it look more "liquid" higher makes it look rigid
		_SwayMax("Sway Max", Range(0, 0.1)) = .005 // how far the swaying goes
		_YOffset("Y offset", float) = 0.5// y offset, below this is no animation
	}
	SubShader
	{
		Tags 
		{
			"RenderType"="Opaque"
			"DisableBatching" = "LODFading"
		}
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;

			float _Speed;
			float _SwayMax;
			float _YOffset;
			float _Rigidness;
			
			v2f vert (appdata v)
			{
				v2f o;

				float3 wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float x = sin(wpos.x / _Rigidness + (_Time.x * _Speed)) *(v.vertex.y - _YOffset) * 5;// x axis movements
				float z = sin(wpos.z / _Rigidness + (_Time.x * _Speed)) *(v.vertex.y - _YOffset) * 5;// z axis movements
				v.vertex.x += step(0,v.vertex.y - _YOffset) * x * _SwayMax;// apply the movement if the vertex's y above the YOffset
				v.vertex.z += step(0,v.vertex.y - _YOffset) * z * _SwayMax;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col * _Color;
			}
			ENDCG
		}
	}
}
