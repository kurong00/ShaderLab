Shader "Custom/Rim/RimEnerge" {
	Properties
    {
        _Color("Main Color",Color) = (0.6,0.6,0.6,1)
        _AlphaRange("Alpha Range",Range(0,1)) = 0
        _RimColor("Rim Color",Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags{ 
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent" }    
		ZWrite Off 
		Blend SrcAlpha OneMinusSrcAlpha 
        LOD 200         

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "Lighting.cginc"      

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;             
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normalDir : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _Color;
            float _AlphaRange;
            fixed4 _RimColor;

            v2f vert( a2v v )
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex) ;
                o.normalDir = UnityObjectToWorldNormal(v.normal); 
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                return o;
            }

            fixed4 frag( v2f v ):COLOR
            {
                float3 normal = normalize(v.normalDir);
                float3 viewDir = normalize(_WorldSpaceCameraPos - v.worldPos);
                float normalDotViewDir = saturate(dot(normal,viewDir));
                fixed3 rim = _RimColor * (1 - normalDotViewDir);
				fixed3 diffuse = normalDotViewDir *_Color;  
                return fixed4(diffuse + rim ,(1 - normalDotViewDir) * (1 - _AlphaRange) + _AlphaRange);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
