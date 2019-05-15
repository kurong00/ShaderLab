Shader "Kurong/Rim/RimLightingOpaque"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		[Normal]_NormalMap("Normal Map", 2D) = "bump" {}
		_RimColor("Rim Color", Color) = (1,1,1,0.0)
		_RimPower("Rim Power", Range(0.5,6.0)) = 1.0
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows

		#pragma target 3.0

		fixed4 _Color;
		sampler2D _NormalMap;
		float4 _RimColor;
		float _RimPower;

		struct Input
		{
			float2 uv_NormalMap;
			float3 viewDir;
		};

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
			o.Albedo = _Color;
			half rim = 1 - saturate(dot(o.Normal,normalize(IN.viewDir)));
			o.Emission = _RimColor.rgb * pow(rim,_RimPower);
		}
		ENDCG
		}
			FallBack "Diffuse"
}
