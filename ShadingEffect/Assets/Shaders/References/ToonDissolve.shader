//lit toon dissolve by @minionsart
Shader "Toon/Lit Dissolve Old" {
	Properties {
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {} 
		_NoiseTex("Dissolve Noise", 2D) = "white"{} // Texture the dissolve is based on
		_NScale ("Noise Scale", Range(0, 10)) = 1 // Color of the dissolve Line
		_DisAmount("Dissolve Amount", Range(0, 1)) = 0 // amount of dissolving going on
		
		_DisLineWidth("Dissolve Width", Range(0, 2)) = 0 // width of the line around the dissolve
		_DisLineColor("Dissolve Color", Color) = (1,1,1,1) // Color of the dissolve Line
			_DisLineColorEx("Dissolve Color Extra", Color) = (1,1,1,1) // Color of the dissolve Line

			[Toggle(ALPHA)] _ALPHA("Show facing parts inside alpha?", Float) = 0
			[Toggle(LIGHTMAP)] _LIGHTMAP("Use 2nd/Lightmap UV?", Float) = 0
	}

		SubShader{
			Tags { "RenderType" = "Transparent" }
			LOD 200
			
			
		Blend SrcAlpha OneMinusSrcAlpha // transparency
CGPROGRAM

#pragma shader_feature LIGHTMAP
#pragma surface surf ToonRamp alphatest:_ALPHA // transparency

sampler2D _Ramp;

// custom lighting function that uses a texture ramp based
// on angle between light direction and normal
#pragma lighting ToonRamp exclude_path:prepass
inline half4 LightingToonRamp (SurfaceOutput s, half3 lightDir, half atten)
{
	#ifndef USING_DIRECTIONAL_LIGHT
	lightDir = normalize(lightDir);
	#endif
	
	half d = dot (s.Normal, lightDir)*0.5 + 0.5;
	half3 ramp = tex2D (_Ramp, float2(d,d)).rgb;
	
	half4 c;
	c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
	//c.a = 0; we don't want the alpha
	c.a = s.Alpha; // use the alpha of the surface output
	return c;
}


sampler2D _MainTex;
float4 _Color;
sampler2D _NoiseTex;// 
float _DisAmount, _NScale;//
float _DisLineWidth;//
float4 _DisLineColor;//
float4 _DisLineColorEx;//


struct Input {
	float2 uv_MainTex : TEXCOORD0;
	float2 uv2_NoiseTex : TEXCOORD1;
	float3 worldPos;// built in value to use the world space position
	
};

void surf (Input IN, inout SurfaceOutput o) {
	half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	half4 n = tex2D(_NoiseTex, IN.worldPos.xy * _NScale); // turn the noise texture into a value we can compare to. worldPos.xy projects from one side, xz from other side, yz from top
#if LIGHTMAP
	n = tex2D(_NoiseTex, IN.uv2_NoiseTex * _NScale);
#endif
	float3 DissolveLineIn = step(n.r - _DisLineWidth, _DisAmount);
	float3 DissolveLineInExtra = step(n.r - (_DisLineWidth + 0.2), _DisAmount) - DissolveLineIn;

	float3 NoDissolve = float3(1, 1, 1) - DissolveLineIn - DissolveLineInExtra;
	c.rgb = (DissolveLineIn * _DisLineColor) + (DissolveLineInExtra * _DisLineColorEx) + (NoDissolve * c.rgb);
	o.Emission = (DissolveLineInExtra * _DisLineColorEx) + (DissolveLineIn * _DisLineColor);
	c.a = step(_DisAmount, n.r);
	
	o.Albedo = c.rgb;
	o.Alpha = c.a;
}
ENDCG

	} 

	Fallback "Diffuse"
}