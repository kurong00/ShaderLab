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

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;             
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normalDir : Texcoord0;
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _Color;
            float _AlphaRange;
            fixed4 _RimColor;

            v2f vert( a2v i )
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.normalDir = mul(float4(i.normal,0),unity_WorldToObject).xyz;
                o.worldPos = mul(unity_ObjectToWorld,i.vertex);
                return o;
            }

            fixed4 frag( v2f v ):COLOR
            {
                float3 normal = normalize(v.normalDir);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - v.worldPos.xyz);
                float NdotV = saturate(dot(normal,viewDir));
                fixed3 diffuse = NdotV *_Color + UNITY_LIGHTMODEL_AMBIENT.rgb;
                float alpha =  1 -  NdotV;      
                fixed3 rim = _RimColor *alpha;  
                return fixed4(diffuse + rim ,alpha * (1-_AlphaRange)+_AlphaRange);
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}
